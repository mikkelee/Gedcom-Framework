//
//  GCAge.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDate;

/**
 
 Gedcom ages can have many forms. This class cluster provides parsing, sorting, and a helper method for calculating ages.
 
 */
@interface GCAge : NSObject <NSCoding, NSCopying>

#pragma mark Initialization

/// @name Creating and initializing ages

/** Initializes and returns an age initialized with a given Gedcom string.
 
 @param gedcom A Gedcom age string.
 @return A new age.
 */
- (id)initWithGedcom:(NSString *)gedcom;

#pragma mark Convenience constructor

/** Returns an age initialized with a given Gedcom string.
 
 @param gedcom A Gedcom age string.
 @return A new age.
 */
+ (id)ageWithGedcom:(NSString *)gedcom;

#pragma mark Helpers

/// @name Helpers

/** Calculates and returns a date created by subtracting `toDate` from `fromDate`.
 
 @param fromDate A GCDate object.
 @param toDate A GCDate object.
 @return A new age.
 */
+ (id)ageFromDate:(GCDate *)fromDate toDate:(GCDate *)toDate;

#pragma mark Comparison

/// @name Comparing ages

/** Compares the receiver to another GCAge.
 
 @param other A GCAge object.
 @return `NSOrderedAscending` if the receiver is younger than other, `NSOrderedDescending` if the receiver is older than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

#pragma mark Objective-C properties

/// @name Gedcom access

/// The date as a Gedcom-compliant string
@property (readonly) NSString *gedcomString;

/// The date as a display-friendly string
@property (readonly) NSString *displayString;

/// @name Accessing properties

/// The years part of the age. 
@property (readonly) NSUInteger years;

/// The months part of the age.
@property (readonly) NSUInteger months;

/// The days part of the age.
@property (readonly) NSUInteger days;

@end
