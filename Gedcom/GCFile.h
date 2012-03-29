//
//  GCFile.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCContext;

@class GCHead;

@interface GCFile : NSObject

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;

+ (id)fileFromGedcomNodes:(NSArray *)nodes;

@property GCHead *head;
@property NSMutableArray *records;

@property (readonly) NSArray *gedcomNodes;

@end
