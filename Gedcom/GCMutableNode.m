//
//  GCMutableNode.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCMutableNode.h"

@interface GCMutableNode ()

@property (weak, nonatomic) GCMutableNode *parent;

@end;

@implementation GCMutableNode {
    NSMutableArray *_subNodes;
}

#pragma mark Initialization

- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSArray *)subNodes
{
    self = [super initWithTag:tag value:value xref:xref subNodes:nil];
    
	if (self) {
        self.lineSeparator = @"\n";
        if (subNodes) {
            for (id subNode in subNodes) {
                [self.mutableSubNodes addObject:subNode];
            }
        } else {
            _subNodes = [NSMutableArray array];
        }
	}
    
	return self;
}

#pragma mark Internal SubNode accessors

- (NSUInteger)countOfMutableSubNodes
{
    return [_subNodes count];
}

- (id)objectInSubNodesAtIndex:(NSUInteger)index
{
    return [_subNodes objectAtIndex:index];
}

- (void)insertObject:(GCMutableNode *)object inMutableSubNodesAtIndex:(NSUInteger)index
{
    return [self insertObject:object inSubNodesAtIndex:index];
}

- (void)insertObject:(GCMutableNode *)node inSubNodesAtIndex:(NSUInteger)index
{
	NSParameterAssert(self != node);
    NSParameterAssert([node isKindOfClass:[GCMutableNode class]]);
    
    if (!_subNodes) {
        _subNodes = [NSMutableArray array];
    }
    
    [_subNodes insertObject:node atIndex:index];
    [node setParent:self];
}

- (void)removeObjectFromMutableSubNodesAtIndex:(NSUInteger)index
{
    return [self removeObjectFromSubNodesAtIndex:index];
}

- (void)removeObjectFromSubNodesAtIndex:(NSUInteger)index
{
    [[_subNodes objectAtIndex:index] setParent:nil];
    [_subNodes removeObjectAtIndex:index];
}

#pragma mark Objective-C properties

- (NSArray *)subNodes
{
    return [_subNodes copy];
}

- (NSMutableArray *)mutableSubNodes
{
    return [self mutableArrayValueForKey:@"subNodes"];
}

@end
