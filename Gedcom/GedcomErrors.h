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
    GCIncorrectValueTypeError = -101,
    GCIncorrectTargetTypeError = -102,
    GCValueMissingError = -103,
    GCTargetMissingError = -104,
    
    GCTooManyValuesError = -201,
    GCTooFewValuesError = -202,
    
    GCUnhandledFileEncodingError = -301
} GCErrorCode;