//
//  GCRelationnship.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCProperty.h"

@class GCEntity;

/**
 
 Relationships are properties that define a relationship between a GCObject and a GCEntity. For example, from a child to a family or from a citation to a source.
 
 */
@interface GCRelationship : GCProperty

#pragma mark Convenience constructors

/// @name Creating relationships

/** Returns an relationship whose type, target, and properties reflect the GCNode.
 
 @param object The object being described.
 @param node A GCNode. Its tag code must correspond to a valid property on the object.
 @return A new relationship.
 */
+ (id)relationshipForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The target of the receiver.
@property GCEntity *target;

@end