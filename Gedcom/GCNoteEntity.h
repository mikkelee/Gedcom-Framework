//
//  GCNoteEntity.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 17/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCEntity.h"

@class GCContext;
@class GCString;
@class GCRecordIdNumberAttribute;

/**
 
 A note entity is used to describe one or more other objects and can be referred to via GCNoteReferenceRelationships.
 
 */
@interface GCNoteEntity : GCEntity

#pragma mark Convenience constructors

/** Returns a note in the given GCContext.
 
 @param context The context of the note.
 @return A new note.
 */
+(GCNoteEntity *)noteInContext:(GCContext *)context;

#pragma mark Obective-C properties

/// The text value of the note.
@property GCString *value;

/// The recordIdNumber of the note.
@property GCRecordIdNumberAttribute *recordIdNumber;

/// Return an array of GCUserReferenceNumberAttribute
@property NSMutableArray *userReferenceNumbers;

/// Returns an array of GCSourceCitationRelationship
@property NSMutableArray *sourceCitations;

/// Returns an array of GCSourceEmbeddedAttribute
@property NSMutableArray *sourceEmbeddeds;

/// Returns an array of GCNoteReferenceRelationship
@property NSMutableArray *noteReferences;

/// Returns an array of GCNoteEmbeddedAttribute
@property NSMutableArray *noteEmbeddeds;

@end
