//
//  GCFile.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCContext;

@class GCHeader;
@class GCEntity;

/**
 
 A file keeps a header and a collection of entities.
 
 */
@interface GCFile : NSObject <NSCoding>

#pragma mark Initialization

/// @name Creating and initializing files

/** Initializes and returns a file initialized with a given context and collection of nodes.
 
 @param context The context to use for the file.
 @param nodes A collection of nodes.
 @return A new file.
 */
- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;

/** Initializes and returns a file initialized with a given header and collection of entities.
 
 The context of the header is used. All entities must be in the same context.
 
 @param header A GCHeader object.
 @param entities A collection of entities.
 @return A new file.
 */
- (id)initWithHeader:(GCHeader *)header entities:(NSArray *)entities;

#pragma mark Convenience constructor

/** Returns a file initialized with a given collection of nodes.
 
 A context will be created for the file.
 
 @param nodes A collection of nodes.
 @return A new file.
 */
+ (id)fileWithGedcomNodes:(NSArray *)nodes;

#pragma mark Node access

- (void)parseNodes:(NSArray *)nodes;

#pragma mark Entity access

/// @name Accessing entities

/** Adds the given entity to the receiver's collection of entities.
  
 @param entity An entity.
 */
- (void)addEntity:(GCEntity *)entity;

/** Removes the given entity from the receiver's collection of entities.
 
 @param entity An entity.
 */
- (void)removeEntity:(GCEntity *)entity;

#pragma mark Objective-C properties

/// The header of the receiver.
@property GCHeader *header;

/// An optional submission entity.
@property GCEntity *submission; //optional

/// @name Accessing entities

/// An ordered collection of all the receiver's entities.
@property (readonly) NSMutableOrderedSet *entities;

/// @name Gedcom output

/// The receiver as an ordered collection of Gedcom nodes.
@property (readonly) NSArray *gedcomNodes;

/// The receiver as a Gedcom string.
@property (readonly) NSString *gedcomString;

@property (weak) id delegate;

@end

@interface GCFile (GCConvenienceMethods)

/// @name Accessing entities

/// An ordered collection of the receiver's families.
@property (readonly) NSMutableOrderedSet *families;

/// An ordered collection of the receiver's individuals.
@property (readonly) NSMutableOrderedSet *individuals;

/// An ordered collection of the receiver's multimedia objects.
@property (readonly) NSMutableOrderedSet *multimediaObjects;

/// An ordered collection of the receiver's notes.
@property (readonly) NSMutableOrderedSet *notes;

/// An ordered collection of the receiver's repositories.
@property (readonly) NSMutableOrderedSet *repositories;

/// An ordered collection of the receiver's sources.
@property (readonly) NSMutableOrderedSet *sources;

/// An ordered collection of the receiver's submitters.
@property (readonly) NSMutableOrderedSet *submitters;

@end

@interface GCFile (GCValidationMethods)

/// @name Validating files

/** Returns whether the receiver is a valid Gedcom file.
 
 If the file is invalid, the error pointer will be updated with an NSError describing the problem.
 
 @param error A pointer to an NSError object
 @return `YES` if the file is valid, otherwise `NO`.
 */
- (BOOL)validateFile:(NSError **)error;

@end