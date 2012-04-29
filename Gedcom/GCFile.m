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

@interface GCTrailer : NSObject
@end
@implementation GCTrailer
@end

@implementation GCFile {
	GCContext *_context;
}

#pragma mark Initialization

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
		_entities = [NSMutableArray arrayWithCapacity:[nodes count]];
		
		for (GCNode *node in nodes) {
            GCTag *tag = [GCTag rootTagWithCode:[node gedTag]];
            Class objectClass = [tag objectClass];
            
            if ([objectClass isEqual:[GCHeader class]]) {
                if (_head) {
                    NSLog(@"Multiple headers!?");
                }
                _head = [GCHeader headerWithGedcomNode:node inContext:context];
            } else if ([objectClass isEqual:[GCEntity class]]) {
                [_entities addObject:[GCEntity entityWithGedcomNode:node inContext:context]];
            } else if ([objectClass isEqual:[GCTrailer class]]) {
                continue; //ignore trailer... 
            } else {
                NSLog(@"Shouldn't happen! %@ unknown class: %@", node, objectClass);
            }
		}
	}
	
	return self;
}

- (id)initWithHeader:(GCHeader *)header entities:(NSArray *)entities
{
    self = [super init];
    
    if (self) {
        _head = header;
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

#pragma mark Entity access

- (void)addEntity:(GCEntity *)entity
{
    NSParameterAssert([[entity context] isEqual:_context]);
    
    [_entities addObject:entity];
}

- (void)removeEntity:(GCEntity *)entity
{
    [_entities removeObject:entity];
}

#pragma mark Objective-C properties

@synthesize head = _head;
@synthesize submission = _submission;
@synthesize entities = _entities;

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[_entities count]+2];
	
	[nodes addObject:[_head gedcomNode]];
    
    if (_submission) {
        [nodes addObject:[_submission gedcomNode]];
    }
	
	for (id entity in _entities) {
		[nodes addObject:[entity gedcomNode]];
	}
	
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

@end

@implementation GCFile (GCConvenienceMethods)

- (id)entitiesOfType:(NSString *)type
{
	NSMutableOrderedSet *entities = [NSMutableOrderedSet orderedSet];
	
	for (GCEntity *entity in _entities) {
		if ([[entity type] isEqualToString:type]) {
			[entities addObject:entity];
		}
	}
	
	return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:entities
                                                              addBlock:^(id obj) {
                                                                  [self addEntity:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeEntity:obj];
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
