//
//  GCRelationnship.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCProperty.h"

@class GCRecord;

/**
 
 Relationships are properties that define a relationship between a GCObject and a GCEntity. For example, from a child to a family or from a citation to a source.
 
 */
@interface GCRelationship : GCProperty

#pragma mark Objective-C properties

/// @name Accessing properties

/// The target of the receiver.
@property (nonatomic) GCRecord *target;

@end

@interface GCRelationship (GCGedcomAccessAdditions)

@property (nonatomic, readonly) Class targetType;

@end