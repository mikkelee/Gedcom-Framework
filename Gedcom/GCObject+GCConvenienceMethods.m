//
//  GCObject+GCConvenienceMethods.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject+GCConvenienceMethods.h"

#import "GCNode.h"
#import "GCContext_internal.h"
#import "GCGedcomLoadingAdditions.h"

@implementation GCObject (GCConvenienceMethods)

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

@end