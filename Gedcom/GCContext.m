//
//  GCContext.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext_internal.h"

#import "GCNodeParser.h"
#import "GCNode.h"

#import "GCEntity.h"

#import "GCHeaderEntity.h"
#import "GCSubmissionEntity.h"
#import "GCFamilyEntity.h"
#import "GCIndividualEntity.h"
#import "GCMultimediaEntity.h"
#import "GCNoteEntity.h"
#import "GCRepositoryEntity.h"
#import "GCSourceEntity.h"
#import "GCSubmitterEntity.h"

#import "GCCharacterSetAttribute.h"
#import "GCHeaderEntity+GCObjectAdditions.h"

#import "GCObject+GCGedcomLoadingAdditions.h"

#import "CharacterSetHelpers.h"

@interface GCTrailerEntity : NSObject //empty class to match trailer objects
@end
@implementation GCTrailerEntity
@end

//TODO: split into categories?
//TODO: merging contexts etc.

@interface NSMapTable (GCSubscriptAdditions)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

@end

@implementation NSMapTable (GCSubscriptAdditions)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id)key
{
    return [self setObject:object forKey:key];
}

@end

@implementation GCContext {
	NSMapTable *_xrefToEntityMap;
    NSMapTable *_entityToXrefMap;
    
    NSMutableArray *_families;
    NSMutableArray *_individuals;
    NSMutableArray *_multimedias;
    NSMutableArray *_notes;
    NSMutableArray *_repositories;
    NSMutableArray *_sources;
    NSMutableArray *_submitters;
    
    NSMutableArray *_customEntities;
    
    dispatch_group_t _group;
    dispatch_queue_t _queue;
}

__strong static NSMapTable *_contextsByName = nil;
__strong static NSArray *_rootKeys = nil;

+ (void)initialize
{
    _contextsByName = [NSMapTable strongToWeakObjectsMapTable];
    _rootKeys = @[ @"families", @"individuals", @"multimedias", @"notes", @"repositories", @"sources", @"submitters" ];
}

- (id)init
{
	self = [super init];
	
	if (self) {
        _name = [[NSUUID UUID] UUIDString];
        
        _xrefToEntityMap = [NSMapTable strongToWeakObjectsMapTable];
        _entityToXrefMap = [NSMapTable weakToStrongObjectsMapTable];
        
        _families = [NSMutableArray array];
        _individuals = [NSMutableArray array];
        _multimedias = [NSMutableArray array];
        _notes = [NSMutableArray array];
        _repositories = [NSMutableArray array];
        _sources = [NSMutableArray array];
        _submitters = [NSMutableArray array];
        
        _customEntities = [NSMutableArray array];
        
        _group = dispatch_group_create();
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"dk.kildekort.Gedcom.context.%@", _name] UTF8String], DISPATCH_QUEUE_SERIAL);
        
        _undoManager = [[NSUndoManager alloc] init];
        
        @synchronized (_contextsByName) {
            _contextsByName[_name] = self;
        }
	}
	
	return self;
}

+ (id)context
{
	return [[self alloc] init];
}

+ (NSDictionary *)contextsByName
{
    @synchronized (_contextsByName) {
        return [_contextsByName copy];
    }
}

#pragma mark Teardown

- (void)dealloc
{
    dispatch_release(_group);
    dispatch_release(_queue);
}

#pragma mark GCNodeParser delegate methods

- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node
{
    dispatch_group_async(_group, _queue, ^{
        GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
        if (tag.objectClass != [GCTrailerEntity class]) {
            (void)[[tag.objectClass alloc] initWithGedcomNode:node inContext:self];
        }
    });
}

- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount
{
    dispatch_group_async(_group, _queue, ^{
        NSLog(@"didParseNodesWithCount: %ld", nodeCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(context:didParseNodesWithEntityCount:)]) {
                [_delegate context:self didParseNodesWithEntityCount:self.countOfEntities];
            }
        });
    });
}

#pragma mark Loading nodes into a context

- (BOOL)parseData:(NSData *)data error:(NSError **)error
{
    GCParameterAssert([self countOfEntities] == 1); // 1 for trailer
    
    GCFileEncoding fileEncoding = encodingForData(data);
    
    GCNodeParser *nodeParser = [[GCNodeParser alloc] init];
    nodeParser.delegate = self;
    
    NSString *gedString = nil;
    
    if (fileEncoding == GCUnknownFileEncoding) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:GCErrorDomain
                                         code:GCUnhandledFileEncodingError
                                     userInfo:@{NSLocalizedDescriptionKey: @"Could not determine encoding for the file."}];
        }
        return NO;
    } else if (fileEncoding == GCANSELFileEncoding) {
        gedString = stringFromANSELData(data);
    } else {
        gedString = [[NSString alloc] initWithData:data encoding:fileEncoding];
    }
    
    BOOL result = [nodeParser parseString:gedString error:error];
    
    dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
    
    return result;
}

- (BOOL)readContentsOfFile:(NSString *)path error:(NSError **)error
{
    return [self parseData:[NSData dataWithContentsOfFile:path] error:error];
}

- (BOOL)readContentsOfURL:(NSURL *)url error:(NSError **)error
{
    return [self parseData:[NSData dataWithContentsOfURL:url] error:error];
}

#pragma mark Saving a context

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile error:(NSError **)error
{
    NSData *dataToWrite = self.gedcomData;
    
    NSDataWritingOptions options = 0;
    
    options |= useAuxiliaryFile ? NSDataWritingAtomic : 0;
    
    return [dataToWrite writeToFile:path options:options error:error];
}

#pragma mark Getting entities by URL

+ (GCEntity *)entityForURL:(NSURL *)url
{
    NSParameterAssert([url.scheme isEqualToString:@"xref"]);
    
    GCContext *context = [GCContext contextsByName][url.host];
    
    return [context _entityForXref:[url.path lastPathComponent] create:NO withClass:nil];
}

#pragma mark Equality

- (BOOL)isEqualTo:(GCObject *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self.gedcomString isEqualToString:object.gedcomString];
}

#pragma mark NSCopying conformance

- (id)copyWithZone:(NSZone *)zone
{
    // deep copy
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        NSString *decodedName = [aDecoder decodeObjectForKey:@"name"];
        
        NSString *key = decodedName;
        int i = 0;
        while (_contextsByName[key]) {
            key = [NSString stringWithFormat:@"%@::%d", decodedName, ++i];
        }
        _name = key;
        _contextsByName[_name] = self;
        
        _xrefToEntityMap = [aDecoder decodeObjectForKey:@"xrefStore"];
        _entityToXrefMap = [aDecoder decodeObjectForKey:@"entityToXref"];
        _header = [aDecoder decodeObjectForKey:@"header"];
        _submission = [aDecoder decodeObjectForKey:@"submission"];
        
        _families = [aDecoder decodeObjectForKey:@"families"];
        _individuals = [aDecoder decodeObjectForKey:@"individuals"];
        _multimedias = [aDecoder decodeObjectForKey:@"multimedias"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
        _repositories = [aDecoder decodeObjectForKey:@"repositories"];
        _sources = [aDecoder decodeObjectForKey:@"sources"];
        _submitters = [aDecoder decodeObjectForKey:@"submitters"];
        
        _customEntities = [aDecoder decodeObjectForKey:@"customEntities"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_xrefToEntityMap forKey:@"xrefStore"];
    [aCoder encodeObject:_entityToXrefMap forKey:@"entityToXref"];
    [aCoder encodeObject:_header forKey:@"header"];
    [aCoder encodeObject:_submission forKey:@"submission"];
    
    [aCoder encodeObject:_families forKey:@"families"];
    [aCoder encodeObject:_individuals forKey:@"individuals"];
    [aCoder encodeObject:_multimedias forKey:@"multimedias"];
    [aCoder encodeObject:_notes forKey:@"notes"];
    [aCoder encodeObject:_repositories forKey:@"repositories"];
    [aCoder encodeObject:_sources forKey:@"sources"];
    [aCoder encodeObject:_submitters forKey:@"submitters"];
    
    [aCoder encodeObject:_customEntities forKey:@"customEntities"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (name: %@ xrefStore: %@)", [super description], _name, _xrefToEntityMap];
}
//COV_NF_END

#pragma mark Xref handling

- (void)_setXref:(NSString *)xref forEntity:(GCEntity *)entity
{
    NSParameterAssert(xref);
    NSParameterAssert(entity);
    NSParameterAssert(!_xrefToEntityMap[xref]);
    
    //NSLog(@"%p: setting xref %@ on %p", self, xref, entity);
    
    // clear previously set xref, if any:
    @synchronized (_entityToXrefMap) {
        @synchronized (_xrefToEntityMap) {
            if (_entityToXrefMap[entity]) {
                [_xrefToEntityMap removeObjectForKey:_entityToXrefMap[entity]];
                [_entityToXrefMap removeObjectForKey:entity];
            }
        }
    }
    
    // update maps:
    @synchronized (_xrefToEntityMap) {
        _xrefToEntityMap[xref] = entity;
    }
    @synchronized (_entityToXrefMap) {
        _entityToXrefMap[entity] = xref;
    }
}

- (NSString *)_xrefForEntity:(GCEntity *)entity
{
    NSParameterAssert(entity);
    NSParameterAssert(entity.gedTag.code);
    
    NSString *xref = nil;
    
    @synchronized (_entityToXrefMap) {
        xref = _entityToXrefMap[entity];
    }
    
    if (!xref) {
        @synchronized (_xrefToEntityMap) {
            int i = 0;
            do {
                xref = [NSString stringWithFormat:@"@%@%d@", entity.gedTag.code, ++i];
            } while (_xrefToEntityMap[xref]);
            
            [self _setXref:xref forEntity:entity];
        }
    }
    
    //NSLog(@"%p: found %@ for %p in %@", self, xref, entity, _entityToXrefMap);
    
    return xref;
}

- (GCEntity *)_entityForXref:(NSString *)xref create:(BOOL)create withClass:(Class)aClass
{
    @synchronized (_xrefToEntityMap) {
        id entity = _xrefToEntityMap[xref];
        if (entity) {
            //NSLog(@"Found existing: %@ > %p", xref, entity);
            return entity;
        } else if (create) {
            entity = [[aClass alloc] initInContext:self];
            //NSLog(@"Creating new: %@ (%@) > %p", xref, aClass, entity);
            [self _setXref:xref forEntity:entity];
            return entity;
        } else {
            //NSLog(@"NOT creating: %@", xref);
            return nil;
        }
    }
}

- (void)_renumberXrefs
{
    _xrefToEntityMap = [NSMapTable strongToWeakObjectsMapTable];
    _entityToXrefMap = [NSMapTable weakToStrongObjectsMapTable];
    
    for (GCEntity *entity in self.entities) {
        (void)[self _xrefForEntity:entity];
    }
}

#pragma mark Xref link methods

- (void)_activateEntity:(GCEntity *)entity
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:didReceiveActionForEntity:)]) {
        [_delegate context:self didReceiveActionForEntity:entity];
    }
}

#pragma mark Custom tag methods

- (BOOL)_shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:shouldHandleCustomTag:forNode:onObject:)]) {
        return [_delegate context:self shouldHandleCustomTag:tag forNode:node onObject:object];
    } else {
        return YES;
    }
}

#pragma mark Objective-C properties

- (GCFileEncoding)fileEncoding
{
    NSString *encoding = _header.characterSet.displayValue;
    
    if ([encoding isEqualToString:@"ANSEL"]) {
        return GCANSELFileEncoding;
    } else if ([encoding isEqualToString:@"ASCII"]) {
        return GCASCIIFileEncoding;
    } else if ([encoding isEqualToString:@"UNICODE"]) {
        return GCUTF16FileEncoding;
    } else if ([encoding isEqualToString:@"UTF-8"]) {
        return GCUTF8FileEncoding;
    } else {
        return GCUnknownFileEncoding;
    }
}

- (void)setFileEncoding:(GCFileEncoding)fileEncoding
{
    GCParameterAssert(_header.characterSet);
    
    NSParameterAssert(fileEncoding != GCUnknownFileEncoding);
    
    NSString *encodingStr;
    
    if (fileEncoding == GCANSELFileEncoding) {
        encodingStr = @"ANSEL";
    } else if (fileEncoding == GCASCIIFileEncoding) {
        encodingStr = @"ASCII";
    } else if (fileEncoding == GCUTF16FileEncoding) {
        encodingStr = @"UNICODE";
    } else {
        NSAssert(false, @"Unhandled file encoding!");
    }
    
    // TODO UTF8?
    
    [_header addAttributeWithType:@"characterSet" value:encodingStr];
}

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[self countOfEntities]];
	
    if (!_header) {
        _header = [GCHeaderEntity defaultHeaderInContext:self];
    }
    
	[nodes addObject:_header.gedcomNode];
    
    if (_submission) {
        [nodes addObject:_submission.gedcomNode];
    }
	
    @synchronized (self) {
        for (GCEntity *entity in self.entities) {
            [nodes addObject:entity.gedcomNode];
        }
	}
    
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

- (NSString *)gedcomString
{
    NSMutableArray *gedcomStrings = [NSMutableArray array];
    
    for (GCNode *node in self.gedcomNodes) {
        [gedcomStrings addObjectsFromArray:node.gedcomLines];
    }
    
    return [gedcomStrings componentsJoinedByString:@"\n"];
}

- (NSData *)gedcomData
{
    GCFileEncoding useEncoding = self.fileEncoding;
    
    NSParameterAssert(useEncoding != GCUnknownFileEncoding);
    NSParameterAssert(useEncoding != GCANSELFileEncoding);
    
    return [self.gedcomString dataUsingEncoding:useEncoding];
}

#pragma mark Accessing entities

- (NSArray *)entities
{
    NSMutableArray *entities = [NSMutableArray array];
    
    for (NSString *entityType in _rootKeys) {
        [entities addObjectsFromArray:[super valueForKey:entityType]];
    }
    
    [entities addObjectsFromArray:_customEntities];
    
	return [entities copy];
}

- (NSMutableArray *)mutableEntities
{
    return [self mutableArrayValueForKey:@"entities"];
}

- (NSUInteger)countOfEntities
{
    NSUInteger count = 0;
    
    if (_header)
        count++;
    if (_submission)
        count++;
    
    @synchronized (self) {
        for (NSString *key in _rootKeys) {
            count += [[self valueForKey:key] count];
        }
    }
    
    count++; //trailer
    
    return count;
}

- (void)_addEntity:(GCEntity *)entity
{
	NSParameterAssert([entity isKindOfClass:[GCEntity class]]);
    
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        self.header = (GCHeaderEntity *)entity;
    } else if ([entity isKindOfClass:[GCSubmissionEntity class]]) {
        self.submission = (GCSubmissionEntity *)entity;
    } else  {
        @synchronized (self) {
            if ([_rootKeys containsObject:entity.gedTag.pluralName]) {
                [[self mutableArrayValueForKey:entity.gedTag.pluralName] addObject:entity];
            } else {
                [_customEntities addObject:entity];
                NSLog(@"entity");
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:self.countOfEntities];
        }
    });
}

- (void)insertObject:(GCEntity *)entity inEntitiesAtIndex:(NSUInteger)index
{
    [self _addEntity:entity];
}

- (void)removeObjectFromEntitiesAtIndex:(NSUInteger)index
{
    GCEntity *entity = self.entities[index];
    
    NSParameterAssert(entity.context == self);
    
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        if (_header == entity) {
            self.header = nil;
        }
    } else if ([entity isKindOfClass:[GCSubmissionEntity class]]) {
        if (_submission == entity) {
            self.submission = nil;
        }
    } else if ([entity isKindOfClass:[GCEntity class]]) {
        @synchronized (self) {
            if ([_rootKeys containsObject:entity.gedTag.pluralName]) {
                [[self mutableArrayValueForKey:entity.gedTag.pluralName] removeObject:entity];
            } else {
                [_customEntities removeObject:entity];
            }
        }
    } else {
        NSAssert(NO, @"Unknown class: %@", entity);
    }
    
    // TODO handle xrefs, remove self as ctx param, and any relationships...
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:self.countOfEntities];
        }
    });
}



- (NSMutableArray *)mutableFamilies {
    return [self mutableArrayValueForKey:@"families"];
}

- (NSUInteger)countOfFamilies {
	return [_families count];
}

- (id)objectInFamiliesAtIndex:(NSUInteger)index {
    return [_families objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inFamiliesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCFamilyEntity class]]);
    NSParameterAssert(obj.context == self);
    [_families insertObject:obj atIndex:index];
}

- (void)removeObjectFromFamiliesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_families[index]).context);
    [_families removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableIndividuals {
    return [self mutableArrayValueForKey:@"individuals"];
}

- (NSUInteger)countOfIndividuals {
	return [_individuals count];
}

- (id)objectInIndividualsAtIndex:(NSUInteger)index {
    return [_individuals objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inIndividualsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCIndividualEntity class]]);
    NSParameterAssert(obj.context == self);
    [_individuals insertObject:obj atIndex:index];
}

- (void)removeObjectFromIndividualsAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_individuals[index]).context);
    [_individuals removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableMultimedias {
    return [self mutableArrayValueForKey:@"multimedias"];
}

- (NSUInteger)countOfMultimedias {
	return [_multimedias count];
}

- (id)objectInMultimediasAtIndex:(NSUInteger)index {
    return [_multimedias objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inMultimediasAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCMultimediaEntity class]]);
    NSParameterAssert(obj.context == self);
    [_multimedias insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediasAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_multimedias[index]).context);
    [_multimedias removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableNotes {
    return [self mutableArrayValueForKey:@"notes"];
}

- (NSUInteger)countOfNotes {
	return [_notes count];
}

- (id)objectInNotesAtIndex:(NSUInteger)index {
    return [_notes objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inNotesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteEntity class]]);
    NSParameterAssert(obj.context == self);
    [_notes insertObject:obj atIndex:index];
}

- (void)removeObjectFromNotesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_notes[index]).context);
    [_notes removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableRepositories {
    return [self mutableArrayValueForKey:@"repositories"];
}

- (NSUInteger)countOfRepositories {
	return [_repositories count];
}

- (id)objectInRepositoriesAtIndex:(NSUInteger)index {
    return [_repositories objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inRepositoriesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCRepositoryEntity class]]);
    NSParameterAssert(obj.context == self);
    [_repositories insertObject:obj atIndex:index];
}

- (void)removeObjectFromRepositoriesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_repositories[index]).context);
    [_repositories removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableSources {
    return [self mutableArrayValueForKey:@"sources"];
}

- (NSUInteger)countOfSources {
	return [_sources count];
}

- (id)objectInSourcesAtIndex:(NSUInteger)index {
    return [_sources objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inSourcesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSourceEntity class]]);
    NSParameterAssert(obj.context == self);
    [_sources insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourcesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_sources[index]).context);
    [_sources removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableSubmitters {
    return [self mutableArrayValueForKey:@"submitters"];
}

- (NSUInteger)countOfSubmitters {
	return [_submitters count];
}

- (id)objectInSubmittersAtIndex:(NSUInteger)index {
    return [_submitters objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inSubmittersAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSubmitterEntity class]]);
    NSParameterAssert(obj.context == self);
    [_submitters insertObject:obj atIndex:index];
}

- (void)removeObjectFromSubmittersAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_submitters[index]).context);
    [_submitters removeObjectAtIndex:index];
}

@end

#pragma mark -

NSString *GCErrorDomain = @"GCErrorDomain";

@implementation GCContext (GCValidationMethods)

- (BOOL)validateContext:(NSError *__autoreleasing *)error
{
    BOOL isValid = YES;
    NSError *returnError = nil;
    
    // TODO validate missing header!
    
    for (GCEntity *entity in self.mutableEntities) {
        //NSLog(@"validating %@", [self xrefForEntity:entity]);
        
        NSError *err = nil;
        
        isValid &= [entity validateObject:&err];
        
        if (err) {
            returnError = combineErrors(returnError, err);
        }
    }
    
    if (!isValid) {
        *error = returnError;
    }
    
    return isValid;
}

@end

#pragma mark -

@implementation GCContext (GCContextKeyValueAdditions)

#pragma mark Subscript accessors

- (id)objectForKeyedSubscript:(id)key
{
    return [super valueForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key
{
    return [self setValue:object forKey:(NSString *)key];
}

@end

#pragma mark -

@implementation GCContext (GCTransactionAdditions)

- (void)beginTransaction
{
    [_undoManager beginUndoGrouping];
}

- (void)rollback
{
    [_undoManager endUndoGrouping];
    [_undoManager undoNestedGroup];
}

- (void)commit
{
    [_undoManager endUndoGrouping];
}

@end