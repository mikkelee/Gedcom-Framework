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
 @return A new attribute.
 */
+ (id)relationshipForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

/** Returns a relationship with a given type.
 
 The relationships's describedObject and target will be nil and must be set manually afterwards.
 
 @param type The type of the relationship.
 @return A new relationship.
 */
+ (id)relationshipWithType:(NSString *)type;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The target of the receiver.
@property GCEntity *target;

@end

@interface GCRelationship (GCConvenienceMethods)

/// @name Creating relationships

/** Returns a relationship with the specified type and target.
 
 @param type The type of the attribute.
 @param target An entity such as an individual or a family.
 @return A new relationship.
 
 */
+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target;

@end