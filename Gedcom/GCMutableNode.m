//
//  GCMutableNode.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCMutableNode.h"

@interface GCMutableNode ()

@property GCNode *parent;

@end;

@implementation GCMutableNode {
    NSMutableArray *_subNodes;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
	if (self) {
        [self setLineSeparator:@"\n"];
        _subNodes = [NSMutableArray array];
	}
    
	return self;
}

#pragma mark Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCMutableNode tag: %@ xref: %@ value: %@ (subNodes: %@)]", [self gedTag], [self xref], [self gedValue], [self subNodes]];
}

#pragma mark Adding subnodes

- (void)addSubNode:(GCMutableNode *)node
{
	NSParameterAssert(self != node);
    NSParameterAssert([node isKindOfClass:[GCMutableNode class]]);
    
    if (!_subNodes) {
        _subNodes = [NSMutableArray array];
    }
    
    [_subNodes addObject:node];
    [node setParent:self];
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
@synthesize subNodes = _subNodes;

@end
