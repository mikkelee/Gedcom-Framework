//
//  GCObject+GCConvenienceAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

@interface GCObject (GCConvenienceAdditions)

@property (nonatomic, readonly) NSArray *relatedRecords;

@end