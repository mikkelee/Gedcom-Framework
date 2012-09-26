//
//  GCXRefStore.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCContextDelegate.h"

@class GCHeaderEntity;
@class GCEntity;
@class GCSubmissionEntity;
@class GCObject;
@class GCNode;
@class GCTag;

typedef enum : NSUInteger {
    GCUnknownFileEncoding = -1,
    GCASCIIFileEncoding = NSASCIIStringEncoding,
    GCUTF8FileEncoding = NSUTF8StringEncoding,
    GCUTF16FileEncoding = NSUTF16StringEncoding,
    GCANSELFileEncoding = kCFStringEncodingANSEL
} GCFileEncoding;

/**
 
 A context encompasses a single file; all entities (that is, individuals, families, etc) in the file will belong to the same context. Generally you'll keep a reference to the context in your Document.
 
 ```
    // create a new context
    GCContext *ctx = [GCContext context];
    
    // optionally set your delegate
    ctx.delegate = ...;
 
    // read a file
    NSError *err = nil;
    BOOL readingSucceeded = [ctx readContentsOfFile:@"/path/to/file.ged" error:&err];
 
    if (!readingSucceeded) {
        // handle error
    }
    
    // work on context, create/modify/delete entities & properties
    
    // TODO save the context back out
 ```
 
 */
@interface GCContext : NSObject <NSCoding>

#pragma mark Obtaining a context
/// @name Obtaining a context

/// Creates and returns a new context.
+ (id)context;

/// Returns a dictionary containing all current contexts, keyed by name.
+ (NSDictionary *)contextsByName;

#pragma mark Parsing nodes
/// @name Parsing nodes

//TODO docs...
/** Causes the receiver to parse the nodes.
 
 Will throw an exception if the receiver already contains entities.
 
 @param nodes A collection of nodes.
 */
- (BOOL)parseNodes:(NSArray *)nodes error:(NSError **)error;

/** Causes the receiver to parse the nodes.
 
 Will throw an exception if the receiver already contains entities.
 
 @param nodes A collection of nodes.
 */
- (BOOL)parseData:(NSData *)data error:(NSError **)error;

/** Causes the receiver to parse the contents of the file.
 
 Will throw an exception if the receiver already contains entities.
 
 If parsing succeeds, 
 
 @param nodes A collection of nodes.
 */
- (BOOL)readContentsOfFile:(NSString *)path error:(NSError **)error;

/** Causes the receiver to parse the nodes.
 
 Will throw an exception if the receiver already contains entities.
 
 @param nodes A collection of nodes.
 */
- (BOOL)readContentsOfURL:(NSURL *)url error:(NSError **)error;

#pragma mark Saving a context

// TODO

#pragma mark - Objective-C properties -

#pragma mark Accessing properties
/// @name Accessing properties

@property (readonly) GCFileEncoding fileEncoding;

/// The name of the receiver.
@property (readonly) NSString *name;

#pragma mark Setting the delegate
/// @name Setting the delegate

/// The receiver's delegate. See GCContextDelegate.
@property (weak) id<NSObject, GCContextDelegate> delegate;

#pragma mark Accessing entities
/// @name Accessing entities

/// A collection of all the receiver's entities.
@property (readonly) NSMutableSet *allEntities;

/// The header of the receiver.
@property GCHeaderEntity *header;

/// An optional submission entity.
@property GCSubmissionEntity *submission;

/// An ordered collection of the receiver's families.
@property (readonly) NSMutableArray *families;

/// An ordered collection of the receiver's individuals.
@property (readonly) NSMutableArray *individuals;

/// An ordered collection of the receiver's multimedia objects.
@property (readonly) NSMutableArray *multimediaObjects;

/// An ordered collection of the receiver's notes.
@property (readonly) NSMutableArray *notes;

/// An ordered collection of the receiver's repositories.
@property (readonly) NSMutableArray *repositories;

/// An ordered collection of the receiver's sources.
@property (readonly) NSMutableArray *sources;

/// An ordered collection of the receiver's submitters.
@property (readonly) NSMutableArray *submitters;

#pragma mark Accessing Gedcom output
/// @name Accessing Gedcom output

/// The receiver as an ordered collection of Gedcom nodes.
@property (readonly) NSArray *gedcomNodes;

/// The receiver as a Gedcom string.
@property (readonly) NSString *gedcomString;

@end

#pragma mark -

@interface GCContext (GCValidationMethods)

/// @name Validating contexts

/** Returns whether the receiver is a valid Gedcom context appropiate for saving to a file.
 
 If the context is invalid, the error pointer will be updated with an NSError describing the problem.
 
 @param error A pointer to an NSError object
 @return `YES` if the context is valid, otherwise `NO`.
 */
- (BOOL)validateContext:(NSError **)error;

@end