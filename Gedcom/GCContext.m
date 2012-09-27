//
//  GCXRefStore.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext_internal.h"

#import "GCNode.h"
#import "GCObject.h"
#import "GCTag.h"
#import "GCString.h"

#import "GCEntity.h"

#import "GCObjects_generated.h"

#import "GCContextDelegate.h"

#import "ValidationHelpers.h"
#import "EncodingHelpers.h"

@interface GCTrailerEntity : NSObject //empty class to match trailer objects
@end
@implementation GCTrailerEntity
@end

//TODO: merging contexts etc.

@implementation GCContext {
	NSMutableDictionary *_xrefToEntityMap;
    NSMutableDictionary *_entityToXrefMap;
	NSMutableDictionary *_xrefToBlockMap;
    NSMutableDictionary *_entityStore;
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
        
        _xrefToEntityMap = [NSMutableDictionary dictionary];
        _entityToXrefMap = [NSMutableDictionary dictionary];
        _xrefToBlockMap = [NSMutableDictionary dictionary];
        _entityStore = [NSMutableDictionary dictionary];
        
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

#pragma mark Node access

- (BOOL)parseNodes:(NSArray *)nodes error:(NSError **)error
{
    NSParameterAssert(nodes);
    NSParameterAssert([nodes count] > 0);
    NSParameterAssert([self countOfEntities] == 1); // 1 for trailer
    
#ifdef DEBUGLEVEL
    clock_t start, end;
    double elapsed;
    start = clock();
#endif
    
    __block NSUInteger handledNodes = 0;
    
    [nodes enumerateObjectsWithOptions:(kNilOptions) usingBlock:^(GCNode *node, NSUInteger idx, BOOL *stop) {
        GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
        
        handledNodes++;
        
        if ([tag.objectClass isSubclassOfClass:[GCTrailerEntity class]]) {
            *stop = YES;
            return;
        } else {
            [tag.objectClass entityWithGedcomNode:node inContext:self];
        }
    }];
    
#ifdef DEBUGLEVEL
    end = clock();
    elapsed = ((double) (end - start)) / CLOCKS_PER_SEC;
    NSLog(@"parseNodes - Time: %f seconds",elapsed);
#endif
    
    if (handledNodes != [nodes count]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:GCErrorDomain
                                         code:GCParsingInconcistencyError
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Inconsistent number of entities after handling nodes: %ld should be %ld (a misplaced TRLR?)", handledNodes, [nodes count]]}];
        }
        
        return NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(context:didFinishWithEntityCount:)]) {
        [_delegate context:self didFinishWithEntityCount:self.countOfEntities];
    }
    
    return YES;
}

- (BOOL)parseData:(NSData *)data error:(NSError **)error
{
    GCFileEncoding fileEncoding = encodingForData(data);
    
    if (fileEncoding == GCUnknownFileEncoding) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:GCErrorDomain
                                         code:GCUnhandledFileEncodingError
                                     userInfo:@{NSLocalizedDescriptionKey: @"Could not determine encoding for the file."}];
        }
        return NO;
    } else if (fileEncoding == GCANSELFileEncoding) {
        NSString *fileString = stringFromANSELData(data);
        
        return [self parseNodes:[GCNode arrayOfNodesFromString:fileString] error:error];
    } else {
        NSString *fileString = [[NSString alloc] initWithData:data encoding:fileEncoding];
        
        return [self parseNodes:[GCNode arrayOfNodesFromString:fileString] error:error];
    }
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

#pragma mark GCEntity collection accessors

- (NSUInteger)countOfEntities
{
    __block NSUInteger count = 0;
    
    if (_header)
        count++;
    if (_submission)
        count++;
    
    @synchronized (_entityStore) {
        [_entityStore enumerateKeysAndObjectsWithOptions:(kNilOptions) usingBlock:^(id key, NSMutableArray *obj, BOOL *stop) {
            count += [obj count];
        }];
    }
    
    count++; //trailer
    
    return count;
}

- (NSEnumerator *)enumeratorOfEntities
{
    NSMutableSet *ents = [NSMutableSet set];
    
    if (_header)
        [ents addObject:_header];
    
    if (_submission)
        [ents addObject:_submission];
    
    @synchronized (_entityStore) {
        for (id ent in [_entityStore allValues]) {
            if ([ent isKindOfClass:[NSArray class]]) {
                [ents addObjectsFromArray:ent];
            } else {
                [ents addObject:ent];
            }
        }
    }
    
    //NSLog(@"ents: %@", ents);
    
    return [ents objectEnumerator];
}

- (GCEntity *)memberOfEntities:(GCEntity *)entity
{
    for (GCEntity *e in [self enumeratorOfEntities]) {
        if ([e isEqual:entity]) {
            return e;
        }
    }
    
    return nil;
}

- (void)addEntitiesObject:(GCEntity *)entity
{
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        NSParameterAssert(!_header);
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
    
    NSString *pointer = [NSString stringWithFormat:@"%p", entity];
    
    @synchronized (_entityToXrefMap) {
        if (_entityToXrefMap[entity]) {
            @synchronized (_xrefToEntityMap) {
                if (_entityToXrefMap[pointer]) {
                    [_xrefToEntityMap removeObjectForKey:_entityToXrefMap[pointer]];
                    [_entityToXrefMap removeObjectForKey:pointer];
                }
            }
        }
    }
    
    //NSLog(@"%p: setting xref %@ on %p", self, xref, entity);
    
    // update maps:
    @synchronized (_xrefToEntityMap) {
        _xrefToEntityMap[xref] = entity;
    }
    @synchronized (_entityToXrefMap) {
        _entityToXrefMap[pointer] = xref;
    }
    
    // call any registered blocks:
    @synchronized (_xrefToBlockMap) {
        if (_xrefToBlockMap[xref]) {
            for (void (^block) (NSString *, GCEntity *) in _xrefToBlockMap[xref]) {
                block(xref, entity);
            }
            [_xrefToBlockMap removeObjectForKey:xref];
        }
    }
}

- (NSString *)_xrefForEntity:(GCEntity *)entity
{
    NSParameterAssert(entity);
    NSParameterAssert(entity.gedTag.code);
    
    NSString *pointer = [NSString stringWithFormat:@"%p", entity];
    
    NSString *xref = nil;
    
    @synchronized (_entityToXrefMap) {
        xref = _entityToXrefMap[pointer];
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
    
    //NSLog(@"%p found %@ for %p in %@", self, xref, entity, _entityToXrefMap);
    
    return xref;
}

- (GCEntity *)_entityForXref:(NSString *)xref
{
    @synchronized (_xrefToEntityMap) {
        return _xrefToEntityMap[xref];
    }
}

- (void)_registerCallbackForXref:(NSString *)xref usingBlock:(void (^)(NSString *xref, GCEntity *entity))block
{
    NSParameterAssert(xref);
    
    @synchronized (_xrefToBlockMap) {
        if ([self _entityForXref:xref]) {
            block(xref, [self _entityForXref:xref]);
        } else	if (_xrefToBlockMap[xref]) {
            [_xrefToBlockMap[xref] addObject:[block copy]];
        } else {
            _xrefToBlockMap[xref] = [NSMutableSet setWithObject:[block copy]];
        }
    }
}

#pragma mark Objective-C properties

- (GCFileEncoding)fileEncoding
{
    NSParameterAssert(_header);
    
    NSString *encoding = _header.characterSet.value.gedcomString;
    
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
    NSParameterAssert(_header);
    
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
    
    _header.characterSet.value = [GCString valueWithGedcomString:encodingStr];
}

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[self countOfEntities]];
	
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

- (NSMutableSet *)allEntities
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
        _xrefToBlockMap = [aDecoder decodeObjectForKey:@"xrefBlocks"];
        _entityStore = [aDecoder decodeObjectForKey:@"entityStore"];
        _header = [aDecoder decodeObjectForKey:@"header"];
        _submission = [aDecoder decodeObjectForKey:@"submission"];
        
        _contextsByName[_name] = self;
        
        _entityToXrefMap = [NSMutableDictionary dictionary];
        [_xrefToEntityMap enumerateKeysAndObjectsUsingBlock:^(id xref, id entity, BOOL *stop) {
            NSString *pointer = [NSString stringWithFormat:@"%p", entity];
            _entityToXrefMap[pointer] = xref;
        }];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_xrefToEntityMap forKey:@"xrefStore"];
    [aCoder encodeObject:_xrefToBlockMap forKey:@"xrefBlocks"];
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

- (void)_activateXref:(NSString *)xref
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:didReceiveActionForEntity:)]) {
        [_delegate context:self didReceiveActionForEntity:[self _entityForXref:xref]];
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
    
    for (GCEntity *entity in self.allEntities) {
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
