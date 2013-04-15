//
//  GCObject+GCConvenienceAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

@class GCValue;
@class GCEntity;

@interface GCObject (GCConvenienceAdditions)

/// @name Accessing GCProperties

/** Creates a GCProperty based on the node and adds it to the receiver via Key-Value coding.
 
 @param node A node.
 */
- (void)addPropertyWithGedcomNode:(GCNode *)node;

/** Creates a collection of GCProperties based on the nodes and adds them to the receiver via Key-Value coding.
 
 @param nodes An array of nodes.
 */
- (void)addPropertiesWithGedcomNodes:(NSArray *)nodes;

@property (nonatomic, readonly) NSArray *relatedEntities;

@end