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
 
 A context encompasses a single file; all entities (that is, individuals, families, etc) in the file will belong to the same context. Generally you'll keep a reference to the context in your Document as it is needed when creating entities.
 
 ```
    // create a new context
    GCContext *ctx = [GCContext context];
    
    // optionally set your delegate
    ctx.delegate = ...;
 
    // read a file
    NSError *readErr = nil;
    BOOL readingSucceeded = [ctx readContentsOfFile:@"/path/to/file.ged" error:&readErr];
 
    if (!readingSucceeded) {
        // handle error
    }
    
    // work on context, create/modify/delete entities & properties
    
    // save the context back out
 
    NSError *writeErr = nil;
    BOOL writingSucceeded = [ctx writeToFile:@"/path..." atomically:YES error:&writeErr];
     
     if (!writingSucceeded) {
         // handle error
     }
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

/** Causes the receiver to parse the nodes.
 
 Will throw an exception if the receiver already contains entities.
 
 @param nodes A collection of nodes.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return `YES` if the parse was successful. If the receiver was unable to parse the nodes, it will return `NO` and set the error pointer to an NSError describing the problem.
 */
- (BOOL)parseNodes:(NSArray *)nodes error:(NSError **)error;

/** Causes the receiver to determine the encoding of the text contained in the data. It will then create an array of nodes and use parseNodes: to parse them. The determined encoding will be available on the fileEncoding property.
 
 Will throw an exception if the receiver already contains entities.
 
 @param data An NSData object containing a Gedcom string in any valid encoding.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return `YES` if the parse was successful. If the receiver was unable to parse the nodes, it will return `NO` and set the error pointer to an NSError describing the problem.
 */
- (BOOL)parseData:(NSData *)data error:(NSError **)error;

/** Causes the receiver to parse the contents of the file into an NSData object and pass it to parseData:error:.
  
 @param path A path to a Gedcom file.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return `YES` if the parse was successful. If the receiver was unable to parse the nodes, it will return `NO` and set the error pointer to an NSError describing the problem.
 */
- (BOOL)readContentsOfFile:(NSString *)path error:(NSError **)error;

/** Causes the receiver to read the contents of the URL into an NSData object and pass it to parseData:error:.
 
 @param url A URL pointing to a Gedcom file.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return `YES` if the parse was successful. If the receiver was unable to parse the nodes, it will return `NO` and set the error pointer to an NSError describing the problem.
 */
- (BOOL)readContentsOfURL:(NSURL *)url error:(NSError **)error;

#pragma mark Saving a context

/** Causes the receiver to write its contents to a file.
 
 @param path A path pointing to the inteded location.
 @param useAuxiliaryFile If `YES`, the contents are written to a backup file, and then—assuming no errors occur—the backup file is renamed to the name specified by path; otherwise, the data is written directly to path.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return `YES` if the write was successful. If the receiver was unable to write its entities, it will return `NO` and set the error pointer to an NSError describing the problem.
 */
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile error:(NSError **)error;

#pragma mark Getting entities by URL

/** Causes the receiver to look up the entity referred to by the URL and return it.
 
 Attributed gedcom strings returned by GCObjects will contain URLs of the form "xref://contextName/xref".
 
 @param url An URL with the scheme `xref://`.
 @return The entity indicated by the URL.
 */
+ (GCEntity *)entityForURL:(NSURL *)url;

#pragma mark - Objective-C properties -

#pragma mark Accessing properties
/// @name Accessing properties

/// The encoding of the file as specified in the header. Modifying this will alter the header. ANSEL is only supported when reading files, not when writing them.
@property GCFileEncoding fileEncoding;

/// The name of the receiver.
@property (readonly) NSString *name;

#pragma mark Setting the delegate
/// @name Setting the delegate

/// The receiver's delegate. See GCContextDelegate.
@property (weak) id<NSObject, GCContextDelegate> delegate;

#pragma mark Accessing entities
/// @name Accessing entities

/// A collection of all the receiver's entities.
@property (readonly) NSMutableSet *mutableEntities;

/// The header of the receiver.
@property GCHeaderEntity *header;

/// An optional submission entity.
@property GCSubmissionEntity *submission;

/// An ordered collection of the receiver's families.
@property (readonly) NSArray *families;

/// An ordered collection of the receiver's individuals.
@property (readonly) NSArray *individuals;

/// An ordered collection of the receiver's multimedia objects.
@property (readonly) NSArray *multimediaObjects;

/// An ordered collection of the receiver's notes.
@property (readonly) NSArray *notes;

/// An ordered collection of the receiver's repositories.
@property (readonly) NSArray *repositories;

/// An ordered collection of the receiver's sources.
@property (readonly) NSArray *sources;

/// An ordered collection of the receiver's submitters.
@property (readonly) NSArray *submitters;

#pragma mark Accessing Gedcom output
/// @name Accessing Gedcom output

/// The receiver as an ordered collection of Gedcom nodes.
@property (readonly) NSArray *gedcomNodes;

/// The receiver as a Gedcom string.
@property (readonly) NSString *gedcomString;

/// The receiver's gedcomString as an NSData object using the encoding from fileEncoding
@property (readonly) NSData *gedcomData;

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