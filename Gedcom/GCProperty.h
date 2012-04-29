//
//  GCProperty.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

/**
 
 Abstract property. Subclasses are GCAttribute and GCRelationship.
 
 */
@interface GCProperty : GCObject

#pragma mark Convenience constructor

/// @name Creating properties

/** Returns a property whose type and properties reflect the GCNode.
 
 Will return either an attribute or a relationship depending on the node.
 
 @param object The object being described.
 @param node A GCNode. Its tag code must correspond to a valid property on the object.
 @return A new attribute.
 */
+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The object being described by the receiver.
@property GCObject *describedObject;

@end
