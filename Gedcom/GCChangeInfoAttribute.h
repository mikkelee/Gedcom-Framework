//
//  GCChangeInfoAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCAttribute.h"
#import "NSObject+MELazyPropertySwizzlingAdditions.h"

/**
 
 An attribute that holds information regarding the change history of an entity.
 
 */
@interface GCChangeInfoAttribute : GCAttribute <MELazyPropertySwizzling>

#pragma mark Objective-C properties

/// Returns the last time the entity was modified.
@property (nonatomic, readonly) NSDate *modificationDate;

/// Property for accessing the following properties
@property (nonatomic) NSArray *notes;

/// Also contained in notes. . GCNoteReferenceRelationship
@property (nonatomic) NSArray *noteReferences;
/// Also contained in notes. . noteReferences
@property (nonatomic) NSMutableArray *mutableNoteReferences;

/// Also contained in notes. . GCNoteEmbeddedAttribute
@property (nonatomic) NSArray *noteEmbeddeds;
/// Also contained in notes. . noteEmbeddeds
@property (nonatomic) NSMutableArray *mutableNoteEmbeddeds;

@end
