//
//  GCDate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCValue.h"

@class GCAge;

/**
 
 Gedcom dates can have many forms. This class cluster provides parsing, sorting, and a helper method for calculating dates.
 
 Parsing dates with the French Republican/Revolutionary calendar is not currently supported.
 
 */
@interface GCDate : GCValue

#pragma mark Convenience constructor

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

#pragma mark Objective-C properties

/// @name Gedcom access

/// The date as a Gedcom-compliant string
@property (readonly) NSString *gedcomString;

/// The date as a display-friendly string
@property (readonly) NSString *displayString;

/// @name Helpers

/// The calendar used by the receiver.
@property (readonly) NSCalendar *calendar;

/// If the date is a range or a period, will return the start of the period (or nil for open-ended), otherwise it will be the same as the date, and identical to maxDate.
@property (readonly) NSDate *minDate;

/// If the date is a range or a period, will return the end of the period, otherwise it will be the same as the date, and identical to minDate.
@property (readonly) NSDate *maxDate;

@end




