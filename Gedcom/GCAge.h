//
//  GCAge.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCValue.h"

@class GCDate;

/**
 
 Gedcom ages can have many forms. This class cluster provides parsing, sorting, and a helper method for calculating ages.
 
 */
@interface GCAge : GCValue

#pragma mark Helpers

/// @name Helpers

/** Calculates and returns a date created by subtracting `toDate` from `fromDate`.
 
 @param fromDate A GCDate object.
 @param toDate A GCDate object.
 @return A new age.
 */
+ (id)ageFromDate:(GCDate *)fromDate toDate:(GCDate *)toDate;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The years part of the age. 
@property (readonly) NSUInteger years;

/// The months part of the age.
@property (readonly) NSUInteger months;

/// The days part of the age.
@property (readonly) NSUInteger days;

@end
