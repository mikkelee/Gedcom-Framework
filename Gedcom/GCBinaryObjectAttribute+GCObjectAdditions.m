//
//  GCBinaryObjectAttribute+GCObjectAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 03/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCBinaryObjectAttribute+GCObjectAdditions.h"

#import "NSData+Base64.h"

@implementation GCBinaryObjectAttribute (GCObjectAdditions)

- (NSData *)blobData
{
    return [NSData dataFromBase64String:self.value.gedcomString];
}

- (NSImage *)image
{
    return [[NSImage alloc] initWithData:self.blobData];
}

@end
