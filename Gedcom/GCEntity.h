//
//  GCEntity.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject_internal.h"
@class GCString;

@interface GCEntity : GCObject

#pragma mark Initialization

/// @name Creating and initializing entities

/** Initializes and returns a entity in the specified context.
 
 @param context The context of the entity.
 @return A new entity.
 */
- (instancetype)initInContext:(GCContext *)context;

/// @name Accessing properties

/// The text value of the entity; most entities have no use for this. Will only be used if the entity accepts values according to its gedTag.
@property (nonatomic) GCString *value;

@end

@interface GCEntity (GCGedcomAccessAdditions)

@property (nonatomic, readonly) BOOL takesValue;

@end