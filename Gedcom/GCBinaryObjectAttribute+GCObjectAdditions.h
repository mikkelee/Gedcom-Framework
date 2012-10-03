//
//  GCBinaryObjectAttribute+GCObjectAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 03/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Gedcom/Gedcom.h>

@interface GCBinaryObjectAttribute (GCObjectAdditions)

@property (readonly, nonatomic) NSData *blobData;

@end
