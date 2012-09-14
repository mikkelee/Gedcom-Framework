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

#import "GCEntity.h"
#import "GCHeaderEntity.h"

#import "GCObjects_generated.h"

#import "GCContextDelegate.h"

@interface GCTrailerEntity : NSObject //empty class to match trailer objects
@end
@implementation GCTrailerEntity
@end

@implementation GCContext {
	NSMutableDictionary *_xrefStore;
	NSMutableDictionary *_xrefBlocks;
    NSMutableDictionary *_entityStore;
}

__strong static NSMutableDictionary *_contextsByName = nil;

+ (void)initialize
{
    _contextsByName = [NSMutableDictionary dictionary];
}

- (id)init
{
	self = [super init];
	
	if (self) {
        _name = [[NSUUID UUID] UUIDString];
        
        _xrefStore = [NSMutableDictionary dictionary];
        _xrefBlocks = [NSMutableDictionary dictionary];
        _entityStore = [NSMutableDictionary dictionary];
	}
    
    _contextsByName[_name] = self;
	
	return self;
}

+ (id)context
{
	return [[self alloc] init];
}

+ (NSDictionary *)contextsByName
{
    return [_contextsByName copy];
}

+ (id)contextWithGedcomNodes:(NSArray *)nodes
{
    GCContext *ctx = [[GCContext alloc] init];
    
    [ctx parseNodes:nodes];
    
    return ctx;
}

+ (id)contextWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    return [[self alloc] initWithContentsOfFile:path usedEncoding:enc error:error];
}

+ (id)contextWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    return [[self alloc] initWithContentsOfURL:url encoding:enc error:error];
}

- (id)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    return nil; //TODO
}

- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    return nil; //TODO
}

#pragma mark Node access

- (void)parseNodes:(NSArray *)nodes
{
    NSParameterAssert([self countOfEntities] == 1);
    
    [nodes enumerateObjectsWithOptions:(kNilOptions) usingBlock:^(GCNode *node, NSUInteger idx, BOOL *stop) {
        GCTag *tag = [GCTag rootTagWithCode:[node gedTag]];
        
        if ([[tag objectClass] isSubclassOfClass:[GCTrailerEntity class]]) {
            *stop = YES;
            return;
        } else {
            [GCEntity entityWithGedcomNode:node inContext:self];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
                [_delegate context:self didUpdateEntityCount:[self countOfEntities]];
            }
        });
    }];
    
    //Note: >= instead of ==... there may be things added during parsing (TODO make this less ugly!)
    NSParameterAssert([self countOfEntities] >= [nodes count]); //dont count trailer
    
    if (_delegate && [_delegate respondsToSelector:@selector(context:didFinishWithEntityCount:)]) {
        [_delegate context:self didFinishWithEntityCount:[self countOfEntities]];
    }
}

#pragma mark Entity access

- (void)addEntity:(GCEntity *)entity
{
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        if (_header) {
            NSLog(@"Multiple headers!?");
        }
        _header = (GCHeaderEntity *)entity;
    } else if ([entity isKindOfClass:[GCSubmissionEntity class]]) {
        _submission = (GCSubmissionEntity *)entity;
    } else if ([entity isKindOfClass:[GCEntity class]]) {
        if (!_entityStore[[entity type]]) {
            _entityStore[[entity type]] = [NSMutableArray array];
        }
        [_entityStore[[entity type]] addObject:entity];
    } else {
        NSLog(@"Unknown class: %@", entity);
    }
    /*
     if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
     [_delegate file:self updatedEntityCount:[_entities count]];
     }*/
}

- (void)removeEntity:(GCEntity *)entity
{
    //TODO
    /*
     if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
     [_delegate file:self updatedEntityCount:[_entities count]];
     }*/
}

- (NSInteger)countOfEntities
{
    __block NSInteger count = 0;
    
    if (_header)
        count++;
    if (_submission)
        count++;
    
    [_entityStore enumerateKeysAndObjectsWithOptions:(kNilOptions) usingBlock:^(id key, NSMutableArray *obj, BOOL *stop) {
        count += [obj count];
    }];
    
    count++; //trailer
    
    return count;
}

#pragma mark Equality

- (BOOL)isEqualTo:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [[self gedcomString] isEqualToString:[object gedcomString]];
}


- (void)setXref:(NSString *)xref forEntity:(GCEntity *)obj
{
    NSParameterAssert(xref);
    NSParameterAssert(obj);
    
    if ([_entityStore[obj.type] containsObject:obj]) {
        for (NSString *key in [_xrefStore allKeysForObject:obj]) {
            [_xrefStore removeObjectForKey:key];
        }
    }
    
    //NSLog(@"%p: setting xref %@ on %p", self, xref, obj);
    
    _xrefStore[xref] = obj;
	
    @synchronized(_xrefBlocks) {
        if (_xrefBlocks[xref]) {
            for (void (^block) (NSString *) in _xrefBlocks[xref]) {
                block(xref);
            }
            [_xrefBlocks removeObjectForKey:xref];
        }
    }
}

- (NSString *)xrefForEntity:(GCEntity *)obj
{
    if (!obj) {
        return nil;
    }
    NSParameterAssert([[obj gedTag] code]);
    
    //NSLog(@"looking for %@ in %@", obj, self);
    
    NSString *xref = nil;
    for (NSString *key in [_xrefStore allKeys]) {
        //NSLog(@"%@: %@", key, [xrefStore objectForKey:key]);
        if (_xrefStore[key] == obj) {
            xref = key;
        }
    }
    
    if (xref == nil) {
        int i = 0;
        do {
            xref = [NSString stringWithFormat:@"@%@%d@", [[obj gedTag] code], ++i];
        } while (_xrefStore[xref]);
        
        [self setXref:xref forEntity:obj];
    }
    
    //NSLog(@"xref: %@", xref);
    
    return xref;
}

- (GCEntity *)entityForXref:(NSString *)xref
{
    return _xrefStore[xref];
}

- (void)registerCallbackForXref:(NSString *)xref usingBlock:(void (^)(NSString *xref))block
{
    NSParameterAssert(xref);
    
    @synchronized (_xrefStore) {
        if ([self entityForXref:xref]) {
            block(xref);
        } else	if (_xrefBlocks[xref]) {
            [_xrefBlocks[xref] addObject:[block copy]];
        } else {
            _xrefBlocks[xref] = [NSMutableSet setWithObject:[block copy]];
        }
    }
}

#pragma mark Objective-C properties

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[self countOfEntities]];
	
	[nodes addObject:[_header gedcomNode]];
    
    if (_submission) {
        [nodes addObject:[_submission gedcomNode]];
    }
	
    for (NSString *key in @[ @"submitter", @"individual", @"family", @"multimediaObject", @"note", @"repository", @"source" ]) {
        for (GCEntity *entity in _entityStore[key]) {
            [nodes addObject:[entity gedcomNode]];
        }
    }
	
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

- (NSString *)gedcomString
{
    NSMutableArray *gedcomStrings = [NSMutableArray array];
    
    for (GCNode *node in [self gedcomNodes]) {
        [gedcomStrings addObjectsFromArray:[node gedcomLines]];
    }
    
    return [gedcomStrings componentsJoinedByString:@"\n"];
}

#pragma mark Accessing entities

- (id)families
{
	return _entityStore[@"family"];
}

- (id)individuals
{
	return _entityStore[@"individual"];
}

- (id)multimediaObjects
{
	return _entityStore[@"multimedia"];
}

- (id)notes
{
	return _entityStore[@"note"];
}

- (id)repositories
{
	return _entityStore[@"repository"];
}

- (id)sources
{
	return _entityStore[@"source"];
}

- (id)submitters
{
	return _entityStore[@"submitter"];
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _xrefStore = [aDecoder decodeObjectForKey:@"xrefStore"];
        _xrefBlocks = [aDecoder decodeObjectForKey:@"xrefBlocks"];
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
    [aCoder encodeObject:_xrefStore forKey:@"xrefStore"];
    [aCoder encodeObject:_xrefBlocks forKey:@"xrefBlocks"];
    [aCoder encodeObject:_header forKey:@"header"];
    [aCoder encodeObject:_submission forKey:@"submission"];
    [aCoder encodeObject:_entityStore forKey:@"entityStore"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (name: %@ xrefStore: %@)", [super description], _name, _xrefStore];
}
//COV_NF_END

#pragma mark Xref link methods

- (void)activateXref:(NSString *)xref
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:didReceiveActionForEntity:)]) {
        [_delegate context:self didReceiveActionForEntity:[self entityForXref:xref]];
    }
}

#pragma mark Unknown tag methods

- (void)encounteredUnknownTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:didEncounterUnknownTag:forNode:onObject:)]) {
        [_delegate context:self didEncounterUnknownTag:tag forNode:node onObject:object];
    }
}

@end

@implementation GCContext (GCValidationMethods)

- (BOOL)validateContext:(NSError *__autoreleasing *)error
{
    if (![_header validateObject:error]) {
        return NO;
    }
    
    if (_submission && ![_submission validateObject:error]) {
        return NO;
    }
    
    for (NSString *key in @[ @"submitter", @"individual", @"family", @"multimediaObject", @"note", @"repository", @"source" ]) {
        for (GCEntity *entity in _entityStore[key]) {
            if (![entity validateObject:error]) {
                return NO;
            }
        }
    }
    
    return YES;
}

@end
