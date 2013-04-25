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
/// @see mutableFamilies.
@property (readonly) NSArray *families;
/// A mutable KVC-compliant collection of the receiver's families.
/// @see families.
@property (readonly) NSMutableArray *mutableFamilies;

/// An ordered collection of the receiver's individuals.
/// @see mutableIndividuals.
@property (readonly) NSArray *individuals;
/// A mutable KVC-compliant collection of the receiver's individuals.
/// @see individuals.
@property (readonly) NSMutableArray *mutableIndividuals;

/// An ordered collection of the receiver's multimedia objects.
/// @see mutableMultimedias.
@property (readonly) NSArray *multimedias;
/// A mutable KVC-compliant collection of the receiver's multimedia objects.
/// @see multimedias.
@property (readonly) NSMutableArray *mutableMultimedias;

/// An ordered collection of the receiver's notes.
/// @see mutableNotes.
@property (readonly) NSArray *notes;
/// A mutable KVC-compliant collection of the receiver's notes.
/// @see notes.
@property (readonly) NSMutableArray *mutableNotes;

/// An ordered collection of the receiver's repositories.
/// @see mutableRepositories.
@property (readonly) NSArray *repositories;
/// A mutable KVC-compliant collection of the receiver's repositories.
/// @see repositories.
@property (readonly) NSMutableArray *mutableRepositories;

/// An ordered collection of the receiver's sources.
/// @see mutableSources.
@property (readonly) NSArray *sources;
/// A mutable KVC-compliant collection of the receiver's sources.
/// @see sources.
@property (readonly) NSMutableArray *mutableSources;

/// An ordered collection of the receiver's submitters.
/// @see mutableSubmitters.
@property (readonly) NSArray *submitters;
/// A mutable KVC-compliant collection of the receiver's submitters.
/// @see submitters.
@property (readonly) NSMutableArray *mutableSubmitters;

/// A collection of all the receiver's entities. That is, the header, submission, families, individuals, etc.
/// @see mutableEntities.
@property (readonly) NSArray *entities;
/// A mutable KVC-compliant collection of the receiver's entities.
/// @see entities.
@property (readonly) NSMutableArray *mutableEntities;

#pragma mark Keyed subscript accessors

/// @name Key-Value coding

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
