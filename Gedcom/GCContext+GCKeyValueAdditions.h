//
//  GCContext+GCKeyValueAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext_internal.h"

#pragma mark -

@interface GCContext (GCKeyValueAdditions)

#pragma mark Accessing entities
/// @name Accessing entities

/// The header of the receiver.
@property GCHeaderEntity *header;

/// An optional submission entity.
@property GCSubmissionRecord *submission;

/// An ordered collection of the receiver's families.
@property (readonly) NSArray *families;
@property (readonly) NSMutableArray *mutableFamilies;

/// An ordered collection of the receiver's individuals.
@property (readonly) NSArray *individuals;
@property (readonly) NSMutableArray *mutableIndividuals;

/// An ordered collection of the receiver's multimedia objects.
@property (readonly) NSArray *multimedias;
@property (readonly) NSMutableArray *mutableMultimedias;

/// An ordered collection of the receiver's notes.
@property (readonly) NSArray *notes;
@property (readonly) NSMutableArray *mutableNotes;

/// An ordered collection of the receiver's repositories.
@property (readonly) NSArray *repositories;
@property (readonly) NSMutableArray *mutableRepositories;

/// An ordered collection of the receiver's sources.
@property (readonly) NSArray *sources;
@property (readonly) NSMutableArray *mutableSources;

/// An ordered collection of the receiver's submitters.
@property (readonly) NSArray *submitters;
@property (readonly) NSMutableArray *mutableSubmitters;

/// A collection of all the receiver's entities.
@property (readonly) NSArray *entities;
@property (readonly) NSMutableArray *mutableEntities;

#pragma mark Keyed subscript accessors

/** Returns the property/ies with the given type. Used like on NSMutableDictionary.
 
 @param key The type of the property.
 @return If the property allows multiple occurrences, will return a KVC-compliant NSMutableArray, otherwise the property itself.
 */
- (id)objectForKeyedSubscript:(id)key;

/** Sets the property for the given type. Used like on NSMutableDictionary
 
 @param object A collection for properties allowing multiple occurrences, otherwise a single property.
 @param key The type of the property.
 */
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key;

@end
