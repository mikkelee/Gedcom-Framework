//
//  GCFile.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCContext;

@class GCHeader;

@interface GCFile : NSObject

#pragma mark Initialization

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;

#pragma mark Convenience constructor

+ (id)fileFromGedcomNodes:(NSArray *)nodes;

#pragma mark Properties

@property GCHeader *head;
@property NSMutableArray *records;

@property (readonly) NSArray *gedcomNodes;

@end
