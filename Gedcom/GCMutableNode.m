//
//  GCMutableNode.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCMutableNode.h"

@interface GCMutableNode ()

@property (weak) GCNode *parent;

@property (readonly) NSMutableOrderedSet *internalSubNodes;

@end;

@implementation GCMutableNode {
    NSMutableOrderedSet *_internalSubNodes;
}

#pragma mark Initialization

- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSOrderedSet *)subNodes
{
    self = [super initWithTag:tag value:value xref:xref subNodes:nil];
    
	if (self) {
        [self setLineSeparator:@"\n"];
        _internalSubNodes = [NSMutableOrderedSet orderedSet];
	}
    
	return self;
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCMutableNode tag: %@ xref: %@ value: %@ (subNodes: %@)]", [self gedTag], [self xref], [self gedValue], [self subNodes]];
}
//COV_NF_END

#pragma mark Internal SubNode accessors

- (NSUInteger)countOfInternalSubNodes
{
    return [_internalSubNodes count];
}

- (id)objectInInternalSubNodesAtIndex:(NSUInteger)index
{
    return [_internalSubNodes objectAtIndex:index];
}

- (void)insertObject:(GCMutableNode *)node inInternalSubNodesAtIndex:(NSUInteger)index
{
	NSParameterAssert(self != node);
    NSParameterAssert([node isKindOfClass:[GCMutableNode class]]);
    
    if (!_internalSubNodes) {
        _internalSubNodes = [NSMutableOrderedSet orderedSet];
    }
    
    [_internalSubNodes insertObject:node atIndex:index];
    [node setParent:self];
}

- (void)removeObjectFromSubNodesAtIndex:(NSUInteger)index
{
    [[_internalSubNodes objectAtIndex:index] setParent:nil];
    [_internalSubNodes removeObjectAtIndex:index];
}

@synthesize internalSubNodes = _internalSubNodes;

#pragma mark Objective-C properties

@synthesize parent = _parent;
@synthesize gedTag = _gedTag;
@synthesize gedValue = _gedValue;
@synthesize xref = _xref;
@synthesize lineSeparator = _lineSeparator;

- (id)subNodes
{
    return [self mutableOrderedSetValueForKey:@"internalSubNodes"];
}

@end
