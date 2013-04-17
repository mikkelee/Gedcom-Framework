//
//  GedcomTypedefs.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSUInteger min;
    NSUInteger max;
} GCAllowedOccurrences;

typedef enum : NSUInteger {
    GCUnknownFileEncoding = -1,
    GCASCIIFileEncoding = NSASCIIStringEncoding,
    GCUTF8FileEncoding = NSUTF8StringEncoding,
    GCUTF16FileEncoding = NSUTF16StringEncoding,
    GCANSELFileEncoding = kCFStringEncodingANSEL
} GCFileEncoding;
