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
@class GCEntity;

@interface GCFile : NSObject

#pragma mark Initialization

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
- (id)initWithHeader:(GCHeader *)header entities:(NSArray *)entities;

#pragma mark Convenience constructor

+ (id)fileWithGedcomNodes:(NSArray *)nodes;

#pragma mark Record access

- (void)addRecord:(GCEntity *)record;
- (void)removeRecord:(GCEntity *)record;

#pragma mark Objective-C properties

@property GCHeader *head;
@property GCEntity *submission; //optional
@property (readonly) NSMutableOrderedSet *records;

@property (readonly) NSArray *gedcomNodes;

@end

@interface GCFile (GCConvenienceMethods)

@property (readonly) NSMutableOrderedSet *families;
@property (readonly) NSMutableOrderedSet *individuals;
@property (readonly) NSMutableOrderedSet *multimediaObjects;
@property (readonly) NSMutableOrderedSet *notes;
@property (readonly) NSMutableOrderedSet *repositories;
@property (readonly) NSMutableOrderedSet *sources;
@property (readonly) NSMutableOrderedSet *submitters;

@end