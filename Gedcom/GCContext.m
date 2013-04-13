//
//  GCXRefStore.m
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
#import "GCCharacterSetAttribute.h"
#import "GCHeaderSourceAttribute.h"
#import "GCDescriptiveNameAttribute.h"
#import "GCGedcomAttribute.h"
#import "GCVersionAttribute.h"
#import "GCGedcomFormatAttribute.h"
#import "GCSubmitterEntity.h"
#import "GCSubmitterReferenceRelationship.h"
#import "GCSubmissionEntity.h"

#import "GCObject+GCGedcomLoadingAdditions.h"

#import "CharacterSetHelpers.h"

@interface GCTrailerEntity : NSObject //empty class to match trailer objects
@end
@implementation GCTrailerEntity
@end

//TODO: split into categories?
//TODO: merging contexts etc.
//TODO: transactions? NSUndoManager group
//TODO: renumber xrefs

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
    NSMutableDictionary *_entityStore;
    dispatch_group_t _group;
    dispatch_queue_t _queue;
}

__strong static NSMutableDictionary *_contextsByName = nil;
__strong static NSArray *_rootKeys = nil;

+ (void)initialize
{
    _contextsByName = [NSMutableDictionary dictionary];
    _rootKeys = @[ @"submitter", @"individual", @"family", @"multimedia", @"note", @"repository", @"source" ];
}

- (id)init
{
	self = [super init];
	
	if (self) {
        _name = [[NSUUID UUID] UUIDString];
        
        _xrefToEntityMap = [NSMapTable strongToStrongObjectsMapTable];
        _entityToXrefMap = [NSMapTable weakToStrongObjectsMapTable];
        _entityStore = [NSMutableDictionary dictionary];
        
        _group = dispatch_group_create();
        _queue = dispatch_queue_create([_name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        
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

#pragma mark Default header

- (void)setDefaultHeader
{
    GCHeaderEntity *head = [GCHeaderEntity headerInContext:self];
    
    head.characterSet = [GCCharacterSetAttribute characterSetWithGedcomStringValue:@"UNICODE"];
    
    head.headerSource = [GCHeaderSourceAttribute headerSourceWithGedcomStringValue:@"Gedcom.framework"];
    head.headerSource.descriptiveName = [GCDescriptiveNameAttribute descriptiveNameWithGedcomStringValue:@"Gedcom.framework"];
    head.headerSource.version = [GCVersionAttribute versionWithGedcomStringValue:@"0.9.1"];
    
    head.gedcom = [GCGedcomAttribute gedcom];
    head.gedcom.version = [GCVersionAttribute versionWithGedcomStringValue:@"5.5"];
    head.gedcom.gedcomFormat = [GCGedcomFormatAttribute gedcomFormatWithGedcomStringValue:@"LINEAGE-LINKED"];
    
    GCSubmitterEntity *subm = [GCSubmitterEntity submitterInContext:self];
    subm.descriptiveName = [GCDescriptiveNameAttribute descriptiveNameWithGedcomStringValue:NSFullUserName()];
    
    head.submitterReference = [GCSubmitterReferenceRelationship submitterReference];
    head.submitterReference.target = subm;
}

#pragma mark GCNodeParser delegate methods

- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    if (tag.objectClass != [GCTrailerEntity class]) {
        dispatch_group_async(_group, _queue, ^{
            (void)[[tag.objectClass alloc] initWithGedcomNode:node inContext:self];
        });
    }
}

- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didParseNodesWithEntityCount:)]) {
            [_delegate context:self didParseNodesWithEntityCount:self.countOfEntities];
        }
    });
}

#pragma mark Loading nodes into a context

- (BOOL)parseNodes:(NSArray *)nodes error:(NSError **)error
{
    GCParameterAssert(nodes);
    GCParameterAssert([nodes count] > 0);
    GCParameterAssert([self countOfEntities] == 1); // 1 for trailer
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:willParseNodes:)]) {
            [_delegate context:self willParseNodes:[nodes count]];
        }
    });
    
#ifdef DEBUGLEVEL
    clock_t start, end;
    double elapsed;
    start = clock();
#endif
    
    NSUInteger handledNodes = 0;
    
    for (GCNode *node in nodes) {
        GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
        
        handledNodes++;
        
        if (tag.objectClass == [GCTrailerEntity class]) {
            break;
        } else {
            (void)[[tag.objectClass alloc] initWithGedcomNode:node inContext:self]; // it will add itself to the context
        }
    }
    
#ifdef DEBUGLEVEL
    end = clock();
    elapsed = ((double) (end - start)) / CLOCKS_PER_SEC;
    NSLog(@"parseNodes - Time: %f seconds",elapsed);
#endif
    
    if (handledNodes != [nodes count]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:GCErrorDomain
                                         code:GCParsingInconcistencyError
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unexpected number of entities after handling nodes: %ld should be %ld (a misplaced TRLR?)", handledNodes, [nodes count]]}];
        }
        
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didParseNodesWithEntityCount:)]) {
            [_delegate context:self didParseNodesWithEntityCount:self.countOfEntities];
        }
    });
    
    return YES;
}

- (BOOL)parseData:(NSData *)data error:(NSError **)error
{
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

#pragma mark GCEntity collection accessors

- (NSUInteger)countOfEntities
{
    NSUInteger count = 0;
    
    if (_header)
        count++;
    if (_submission)
        count++;
    
    @synchronized (_entityStore) {
        for (NSMutableArray *obj in [_entityStore objectEnumerator]) {
            count += [obj count];
        }
    }
    
    count++; //trailer
    
    return count;
}

- (NSEnumerator *)enumeratorOfEntities
{
    NSMutableSet *entities = [NSMutableSet set];
    
    if (_header)
        [entities addObject:_header];
    
    if (_submission)
        [entities addObject:_submission];
    
    @synchronized (_entityStore) {
        for (id entity in [_entityStore allValues]) {
            if ([entity isKindOfClass:[NSArray class]]) {
                [entities addObjectsFromArray:entity];
            } else {
                [entities addObject:entity];
            }
        }
    }
    
    return [entities objectEnumerator];
}

- (GCEntity *)memberOfEntities:(GCEntity *)anEntity
{
    for (GCEntity *entity in [self enumeratorOfEntities]) {
        if ([entity isEqual:anEntity]) {
            return entity;
        }
    }
    
    return nil;
}

- (void)addEntitiesObject:(GCEntity *)entity
{
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        self.header = (GCHeaderEntity *)entity;
    } else if ([entity isKindOfClass:[GCSubmissionEntity class]]) {
        self.submission = (GCSubmissionEntity *)entity;
    } else if ([entity isKindOfClass:[GCEntity class]]) {
        @synchronized (_entityStore) {
            if (!_entityStore[entity.type]) {
                _entityStore[entity.type] = [NSMutableArray array];
            }
            [self willChangeValueForKey:entity.type];
            [_entityStore[entity.type] addObject:entity];
            [self didChangeValueForKey:entity.type];
        }
    } else {
        NSAssert(NO, @"Unknown class: %@", entity);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:self.countOfEntities];
        }
    });
}

- (void)removeEntitiesObject:(GCEntity *)entity
{
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
        @synchronized (_entityStore) {
            [self willChangeValueForKey:entity.type];
            [_entityStore[entity.type] removeObject:entity];
            [self didChangeValueForKey:entity.type];
        }
    } else {
        NSAssert(NO, @"Unknown class: %@", entity);
    }
    
    // TODO handle xrefs and any relationships...
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:self.countOfEntities];
        }
    });
}

#pragma mark Equality

- (BOOL)isEqualTo:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self.gedcomString isEqualToString:[(GCContext *)object gedcomString]];
}

#pragma mark Xref handling

- (void)_setXref:(NSString *)xref forEntity:(GCEntity *)entity
{
    NSParameterAssert(xref);
    NSParameterAssert(entity);
    
    //NSLog(@"%p: setting xref %@ on %p", self, xref, entity);
    
    // TODO - check if xref is used already!
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
        [self setDefaultHeader];
    }
    
	[nodes addObject:_header.gedcomNode];
    
    if (_submission) {
        [nodes addObject:_submission.gedcomNode];
    }
	
    @synchronized (_entityStore) {
        for (NSString *key in _rootKeys) {
            for (GCEntity *entity in _entityStore[key]) {
                [nodes addObject:entity.gedcomNode];
            }
        }
        
        NSMutableSet *presentKeys = [NSMutableSet setWithArray:[_entityStore allKeys]];
        [presentKeys minusSet:[NSSet setWithArray:_rootKeys]];
        
        for (NSString *customKey in presentKeys) {
            //NSLog(@"Custom key: %@", customKey);
            for (GCEntity *entity in _entityStore[customKey]) {
                [nodes addObject:entity.gedcomNode];
            }
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

- (id)families
{
	return [_entityStore[@"family"] copy];
}

- (id)individuals
{
	return [_entityStore[@"individual"] copy];
}

- (id)multimediaObjects
{
	return [_entityStore[@"multimedia"] copy];
}

- (id)notes
{
	return [_entityStore[@"note"] copy];
}

- (id)repositories
{
	return [_entityStore[@"repository"] copy];
}

- (id)sources
{
	return [_entityStore[@"source"] copy];
}

- (id)submitters
{
	return [_entityStore[@"submitter"] copy];
}

- (NSMutableSet *)mutableEntities
{
    return [self mutableSetValueForKey:@"entities"];
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _xrefToEntityMap = [aDecoder decodeObjectForKey:@"xrefStore"];
        _entityToXrefMap = [aDecoder decodeObjectForKey:@"entityToXref"];
        _entityStore = [aDecoder decodeObjectForKey:@"entityStore"];
        _header = [aDecoder decodeObjectForKey:@"header"];
        _submission = [aDecoder decodeObjectForKey:@"submission"];
        
        _contextsByName[_name] = self;
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
    [aCoder encodeObject:_entityStore forKey:@"entityStore"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (name: %@ xrefStore: %@)", [super description], _name, _xrefToEntityMap];
}
//COV_NF_END

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
