//
//  GCMutableNode.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCMutableNode.h"

#import "GCMutableOrderedSetProxy.h"

@interface GCMutableNode ()

@property (weak) GCNode *parent;

@end;

@implementation GCMutableNode {
    NSMutableOrderedSet *_subNodes;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
	if (self) {
        [self setLineSeparator:@"\n"];
        _subNodes = [NSMutableOrderedSet orderedSet];
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

#pragma mark Adding subnodes

- (void)addSubNode:(GCMutableNode *)node
{
	NSParameterAssert(self != node);
    NSParameterAssert([node isKindOfClass:[GCMutableNode class]]);
    
    if (!_subNodes) {
        _subNodes = [NSMutableOrderedSet orderedSet];
    }
    
    [_subNodes addObject:node];
    [node setParent:self];
}

- (void)removeSubNode: (GCMutableNode *) node
{
    NSParameterAssert([node parent] == self);
    
    [_subNodes removeObject:node];
    [node setParent:nil];
}

- (void)addSubNodes:(NSArray *)subNodes
{
	for (id subNode in subNodes) {
		[self addSubNode:subNode];
	}
}

#pragma mark Objective-C properties

@synthesize parent = _parent;
@synthesize gedTag = _gedTag;
@synthesize gedValue = _gedValue;
@synthesize xref = _xref;
@synthesize lineSeparator = _lineSeparator;

- (id)subNodes
{
    return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:_subNodes
                                                              addBlock:^(id obj) {
                                                                  [self addSubNode:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeSubNode:obj];
                                                           }];

}

- (void)setSubNodes:(NSOrderedSet *)subNodes
{
    _subNodes = [NSMutableOrderedSet orderedSetWithCapacity:[subNodes count]];
    
    for (id subNode in subNodes) {
        [self addSubNode:subNode];
    }

}

@end
