//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

@class GCString;

/**
 
 Entities are objects such as an individual or a family.
 
 */
@interface GCEntity : GCObject

#pragma mark Initialization

/// @name Creating and initializing entities

/** Initializes and returns a entity in the specified context.
 
 @param context The context of the entity.
 @return A new entity.
 */
- (id)initInContext:(GCContext *)context;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The last time the entity was modified. Will access the entity's GCChangeInfoAttribute to obtain the info. Note that every KVC-compliant change made to the entity will cause the change info to update.
@property (readonly, nonatomic) NSDate *modificationDate;

/// The text value of the entity; most entities have no use for this. Will only be used if the entity accepts values according to its gedTag.
@property (nonatomic) GCString *value;

@end

@interface GCEntity (GCGedcomLoadingAdditions)

/** Returns an entity whose properties reflect the GCNode in the given GCContext.
 
 @param node A GCNode. Its tag code must correspond to a valid root object.
 @param context The context of the entity.
 @return A new entity.
 */
- (id)initWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

@end