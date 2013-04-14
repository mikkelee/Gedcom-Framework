//
//  GedcomErrors.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *GCErrorDomain;

typedef enum : NSInteger {
    // context errors:
    GCUnhandledFileEncodingError = -1,
    GCParsingInconcistencyError = -2,
    
    // validation errors:
    GCIncorrectValueTypeError = -101,
    GCIncorrectTargetTypeError = -102,
    GCValueMissingError = -103,
    GCTargetMissingError = -104,
    
    // validation errors cont'd:
    GCTooManyValuesError = -201,
    GCTooFewValuesError = -202,
    
    // sanity checking:
    GCSanityCheckInconsistency = -301,
    
    // parser errors:
    GCNodeParsingError = -401,
} GCErrorCode;

static inline NSError * combineErrors(NSError *originalError, NSError *secondError) {
    if (!originalError) {
        return secondError;
    } else if (!secondError) {
        return originalError;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];
    
    if ([originalError code] == NSValidationMultipleErrorsError) {
        
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    } else {
        [errors addObject:originalError];
    }
    
    [userInfo setObject:errors forKey:NSDetailedErrorsKey];
    
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError
                           userInfo:userInfo];
}