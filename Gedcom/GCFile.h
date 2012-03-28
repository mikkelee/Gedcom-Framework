//
//  GCFile.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCObject;
@class GCNode;

@interface GCFile : NSObject

+ (id)fileFromGedcomNodes:(NSArray *)nodes;

@property GCObject *head;
@property NSMutableArray *records;

@end
