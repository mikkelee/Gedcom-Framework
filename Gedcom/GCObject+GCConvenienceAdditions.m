//
//  GCObject+GCConvenienceAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject+GCConvenienceAdditions.h"

#import "GCNode.h"
#import "GCContext_internal.h"
#import "GCGedcomLoadingAdditions.h"
#import "GCRelationship.h"

@implementation GCObject (GCConvenienceAdditions)

- (void)addPropertyWithGedcomNode:(GCNode *)node
{
    GCTag *tag = [self.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (tag.isCustom) {
        if (![self.context _shouldHandleCustomTag:tag forNode:node onObject:self]) {
            return;
        }
    }
    
    (void)[[tag.objectClass alloc] initWithGedcomNode:node onObject:self];
}

- (void)addPropertiesWithGedcomNodes:(NSArray *)nodes
{
    for (id node in nodes) {
        [self addPropertyWithGedcomNode:node];
    }
}

- (NSArray *)relatedEntities
{
    NSMutableArray *targets = [NSMutableArray array];
    
    for (GCObject *object in self.properties) {
        if ([object isKindOfClass:[GCRelationship class]]) {
            [targets addObject:((GCRelationship *)object).target];
        }
        [targets addObjectsFromArray:object.relatedEntities];
    }
    
    return [targets copy];
}

@end