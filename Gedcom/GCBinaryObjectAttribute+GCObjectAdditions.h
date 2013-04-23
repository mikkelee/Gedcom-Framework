//
//  GCBinaryObjectAttribute+GCObjectAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 03/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCBinaryObjectAttribute.h"

@interface GCBinaryObjectAttribute (GCObjectAdditions)

/// @name Accessing properties

/// Helper for accessing the data encoded in the BLOB.
@property (readonly, nonatomic) NSData *blobData;

/// Helper for parsing the data as an image.
@property (readonly, nonatomic) NSImage *image;

@end
