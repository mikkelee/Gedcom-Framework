//
//  GCFile.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCFile.h"
#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCContext.h"

#import "GCHeaderEntity.h"
#import "GCEntity.h"

#import "GCObjects_generated.h"

#import "GCFileDelegate.h"

@interface GCTrailerEntity : NSObject //empty class to match trailer objects
@end
@implementation GCTrailerEntity
@end

@implementation GCFile {
    NSMutableDictionary *_entityStore;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if (self) {
        _context = [GCContext context];
        _entityStore = [NSMutableDictionary dictionaryWithCapacity:7];
    }
    
    return self;
}

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
        _entityStore = [NSMutableDictionary dictionaryWithCapacity:7];
		
        [self parseNodes:nodes];
	}
	
	return self;
}

- (id)initWithHeader:(GCHeaderEntity *)header entities:(NSArray *)entities
{
    self = [super init];
    
    if (self) {
        _header = header;
        _context = [header context];
        _entityStore = [NSMutableDictionary dictionaryWithCapacity:7];
        
        for (GCEntity *entity in entities) {
            NSParameterAssert(_context == [entity context]);
            
            [self addEntity:entity];
        }
    }
    
    return self;
}

#pragma mark Convenience constructor

+ (id)fileWithGedcomNodes:(NSArray *)nodes
{
	return [[self alloc] initWithContext:[GCContext context] gedcomNodes:nodes];
}

#pragma mark Node access

- (void)parseNodes:(NSArray *)nodes
{
    NSParameterAssert([self countOfEntities] == 0);
    
    [nodes enumerateObjectsWithOptions:(kNilOptions) usingBlock:^(GCNode *node, NSUInteger idx, BOOL *stop) {
        GCTag *tag = [GCTag rootTagWithCode:[node gedTag]];
        
        if ([[tag objectClass] isSubclassOfClass:[GCTrailerEntity class]]) {
            *stop = YES;
            return;
        } else {
            GCEntity *entity = [GCEntity entityWithGedcomNode:node inContext:_context];
            
            [self addEntity:entity];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(file:didUpdateEntityCount:)]) {
                [_delegate file:self didUpdateEntityCount:[self countOfEntities]];
            }
        });
    }];
    
    
    NSParameterAssert([self countOfEntities] == [nodes count]-1); //dont count trailer
    
    if (_delegate && [_delegate respondsToSelector:@selector(file:didFinishWithEntityCount:)]) {
        [_delegate file:self didFinishWithEntityCount:[self countOfEntities]];
    }
}

#pragma mark Entity access

- (void)addEntity:(GCEntity *)entity
{
    NSParameterAssert([[entity context] isEqual:_context]);
    
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

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
        _header = [aDecoder decodeObjectForKey:@"header"];
        _submission = [aDecoder decodeObjectForKey:@"submission"];
        _entityStore = [aDecoder decodeObjectForKey:@"entityStore"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_context forKey:@"context"];
    [aCoder encodeObject:_header forKey:@"header"];
    [aCoder encodeObject:_submission forKey:@"submission"];
    [aCoder encodeObject:_entityStore forKey:@"entityStore"];
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

@end

@implementation GCFile (GCValidationMethods)

- (BOOL)validateFile:(NSError *__autoreleasing *)error
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