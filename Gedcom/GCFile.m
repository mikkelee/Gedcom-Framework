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

#import "GCHeader.h"
#import "GCEntity.h"

#import "GCMutableOrderedSetProxy.h"

#import "GCFileDelegate.h"

@interface GCTrailer : NSObject
@end
@implementation GCTrailer
@end

@implementation GCFile {
	GCContext *_context;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if (self) {
        _context = [GCContext context];
		_entities = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
		_entities = [NSMutableArray arrayWithCapacity:[nodes count]];
		
        [self parseNodes:nodes];
	}
	
	return self;
}

- (id)initWithHeader:(GCHeader *)header entities:(NSArray *)entities
{
    self = [super init];
    
    if (self) {
        _header = header;
        _context = [header context];
        
        _entities = [NSMutableOrderedSet orderedSetWithCapacity:[entities count]];
        
        for (GCEntity *entity in entities) {
            NSParameterAssert(_context == [entity context]);
            
            [_entities addObject:entity];
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
    for (GCNode *node in nodes) {
        GCTag *tag = [GCTag rootTagWithCode:[node gedTag]];
        Class objectClass = [tag objectClass];
        
        if ([objectClass isEqual:[GCHeader class]]) {
            if (_header) {
                NSLog(@"Multiple headers!?");
            }
            _header = [GCHeader headerWithGedcomNode:node inContext:_context];
        } else if ([objectClass isEqual:[GCEntity class]]) {
            [_entities addObject:[GCEntity entityWithGedcomNode:node inContext:_context]];
        } else if ([objectClass isEqual:[GCTrailer class]]) {
            continue; //ignore trailer... 
        } else {
            NSLog(@"Shouldn't happen! %@ unknown class: %@", node, objectClass);
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
            [_delegate file:self updatedEntityCount:[_entities count]];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(file:didFinishWithEntityCount:)]) {
        [_delegate file:self didFinishWithEntityCount:[_entities count]];
    }
}

#pragma mark Entity access

- (void)addEntity:(GCEntity *)entity
{
    NSParameterAssert([[entity context] isEqual:_context]);
    
    [_entities addObject:entity];
    
    if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
        [_delegate file:self updatedEntityCount:[_entities count]];
    }
}

- (void)removeEntity:(GCEntity *)entity
{
    [_entities removeObject:entity];
    
    if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
        [_delegate file:self updatedEntityCount:[_entities count]];
    }
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
        _entities = [aDecoder decodeObjectForKey:@"entities"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_context forKey:@"context"];
    [aCoder encodeObject:_header forKey:@"header"];
    [aCoder encodeObject:_entities forKey:@"entities"];
}

#pragma mark Objective-C properties

@synthesize header = _header;
@synthesize submission = _submission;
@synthesize entities = _entities;

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[_entities count]+2];
	
	[nodes addObject:[_header gedcomNode]];
    
    if (_submission) {
        [nodes addObject:[_submission gedcomNode]];
    }
	
	for (id entity in _entities) {
		[nodes addObject:[entity gedcomNode]];
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

@synthesize delegate = _delegate;

@end

@implementation GCFile (GCConvenienceMethods)

- (id)entitiesPassingTest:(BOOL (^)(id obj))block
{
	NSMutableOrderedSet *entities = [NSMutableOrderedSet orderedSet];
	
    NSIndexSet *indexes = [_entities indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    NSUInteger idx = [indexes firstIndex];
    
    while(idx != NSNotFound) {
		[entities addObject:[_entities objectAtIndex:idx]];
        idx = [indexes indexGreaterThanIndex:idx];
    }
	
	return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:entities
                                                              addBlock:^(id obj) {
                                                                  [self addEntity:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeEntity:obj];
                                                           }];
}

- (id)entitiesOfType:(NSString *)type
{
    return [self entitiesPassingTest:^BOOL(id obj) {
        return [[(GCEntity *)obj type] isEqualToString:type];
    }];
}

- (id)families
{
	return [self entitiesOfType:@"Family record"];
}

- (id)individuals
{
	return [self entitiesOfType:@"Individual record"];
}

- (id)multimediaObjects
{
	return [self entitiesOfType:@"Multimedia record"];
}

- (id)notes
{
	return [self entitiesOfType:@"Note record"];
}

- (id)repositories
{
	return [self entitiesOfType:@"Repository record"];
}

- (id)sources
{
	return [self entitiesOfType:@"Source record"];
}

- (id)submitters 
{
	return [self entitiesOfType:@"Submitter record"];
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
    
    for (GCEntity *entity in _entities) {
        if (![entity validateObject:error]) {
            return NO;
        }
    }
    
    return YES;
}

@end