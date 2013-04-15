//
//  GCValidationAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"
#import "GCObject_internal.h"

@interface GCContext (GCValidationAdditions)

/// @name Validating contexts

/** Returns whether the receiver is a valid Gedcom context appropiate for saving to a file.
 
 If the context is invalid, the error pointer will be updated with an NSError describing the problem.
 
 @param error A pointer to an NSError object
 @return `YES` if the context is valid, otherwise `NO`.
 */
- (BOOL)validateContext:(NSError **)error;

@end

@interface GCObject (GCValidationMethods)

/// @name Validating objects

/** Returns whether the receiver is a valid Gedcom object.
 
 If the object is invalid, the error pointer will be updated with an NSError describing the problem.
 
 @param error A pointer to an NSError object
 @return `YES` if the object is valid, otherwise `NO`.
 */
- (BOOL)validateObject:(NSError **)error;

@end