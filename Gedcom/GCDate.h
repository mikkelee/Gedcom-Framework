//
//  GCDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCValue.h"

@class GCAge;

/**
 
 Gedcom dates can have many forms. This class cluster provides parsing, sorting, and a helper method for calculating dates.
 
 */
@interface GCDate : GCValue

#pragma mark Initialization

/// @name Creating and initializing dates
/** Initializes and returns a date initialized with a given Gedcom string.
 
 @param gedcom A Gedcom date string.
 @return A new date.
 */
- (id)initWithGedcom:(NSString *)gedcom;

/** Initializes and returns a date initialized with a given NSDate object.
 
 @param date An NSDate object.
 @return A new date.
 */
- (id)initWithDate:(NSDate *)date;

#pragma mark Convenience constructor

/** Returns a date created with a given Gedcom string.
 
 @param gedcom An NSDate object.
 @return A new date.
 */
+ (id)valueWithGedcomString:(NSString *)gedcom;

/** Returns a date created with a given NSDate object.
 
 @param date An NSDate object.
 @return A new date.
 */
+ (id)dateWithDate:(NSDate *)date;

#pragma mark Helpers

/// @name Helpers
/** Returns a date created by adding the given age to the receiver.
 
 @param age A GCAge object.
 @return A new date.
 */
- (id)dateByAddingAge:(GCAge *)age;

/** Returns a boolean value indicating whether the given date is contained within the receiver.
 
 If the date is larger than receiver's minDate and less than receiver's maxDate, the result is NO.
 
 @param date an NSDate object.
 @return `YES` if date is contained in the receiver, otherwise `NO`.
 */
- (BOOL)containsDate:(NSDate *)date;

#pragma mark Comparison

/// @name Comparing dates
/** Compares the receiver to another GCDate.
 
 @param other A GCDate object.
 @return `NSOrderedAscending` if the receiver is earlier than other, `NSOrderedDescending` if the receiver is later than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

#pragma mark Objective-C properties

/// @name Gedcom access

/// The date as a Gedcom-compliant string
@property (readonly) NSString *gedcomString;

/// The date as a display-friendly string
@property (readonly) NSString *displayString;

/// @name Helpers

/// If the date is a range or a period, will return the start of the period, otherwise it will be the same as the date, and identical to maxDate.
@property (readonly) NSDate *minDate;

/// If the date is a range or a period, will return the end of the period, otherwise it will be the same as the date, and identical to minDate.
@property (readonly) NSDate *maxDate;

/// @name Property access

/// The year of the date. If the date is a range or a period, the year will be in the middle.
@property (readonly) NSUInteger year;

/// The month of the date.
@property (readonly) NSUInteger month;

/// The month of the date.
@property (readonly) NSUInteger day;

@end




