//
//  GCChangeInfoAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCAttribute.h"

/**
 
 An attribute that holds information regarding the change history of an entity.
 
 */
@interface GCChangeInfoAttribute : GCAttribute

/** Returns a new change info attribute.
 
 @return A new change info attribute.
 */
+(GCChangeInfoAttribute *)changeInfo;

#pragma mark Objective-C properties

/// Returns the last time the entity was modified.
@property (readonly) NSDate *modificationDate;

/// Returns an array of GCNoteReferenceRelationship
@property NSMutableArray *noteReferences;

/// Returns an array of GCNoteEmbeddedAttribute
@property NSMutableArray *noteEmbeddeds;

@end
