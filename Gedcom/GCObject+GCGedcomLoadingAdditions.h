//
//  GCObject+GCGedcomLoadingAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 13/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"
#import "GCProperty.h"

@class GCNode;
@class GCContext;

@interface GCEntity (GCGedcomLoadingAdditions)

/** Returns an entity whose properties reflect the GCNode in the given GCContext.
 
 @param node A GCNode. Its tag code must correspond to a valid root object.
 @param context The context of the entity.
 @return A new entity.
 */
- (id)initWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

@end

@interface GCProperty (GCGedcomLoadingAdditions)

#pragma mark Initialization

/// @name Creating and initializing properties

/** Initializes and creates a property whose type and properties reflect the GCNode.
 
 Cannot be used to initialize the GCProperty superclass, but must be used on the GCAttribute and GCRelationship subclasses.
 
 @param object The object being described.
 @param node A GCNode. Its tag code must correspond to a valid property on the object.
 @return A new attribute.
 */
- (id)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object;

@end