//
//  GCValue.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 The value of an attribute.
 
 GCValue objects are abstract and immutable. To change the value of a GCAttribute, assign a new value object to it.
 
 Use one of the following subclasses:
 
 GCString,
 GCNamestring,
 GCPlacestring,
 GCNumber,
 GCDate,
 GCAge,
 GCGender, or
 GCBool.
 
 */
@interface GCValue : NSObject <NSCoding, NSCopying>

/// @name Creating values

/** Returns a new Gedcom value interpreted from the given string.
 
 `GCValue`s cannot be created directly, but must be done via a subclass.
 
 @param gedcomString a Gedcom string.
 @return A new value.
 
 */
+ (instancetype)valueWithGedcomString:(NSString *)gedcomString;

/// @name Comparing values

/** Compares the receiver to another GCValue.
 
 The exact comparison method chosen depends on the subclass.
 
 @param other A GCValue object.
 @return `NSOrderedAscending` if the receiver is earlier than other, `NSOrderedDescending` if the receiver is later than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

/// @name Gedcom access

/// The value as a Gedcom-compliant string. Consider using the appropiate GCalueFormatter subclass.
@property (readonly) NSString *gedcomString;

/// @name Displaying values

/// The value as a display-friendly string. Consider using the appropiate GCalueFormatter subclass.
@property (readonly) NSString *displayString;
@property (readonly) NSString *shortDisplayString;

@end

/**
 
 A Gedcom string value. Its string value can be accessed via -gedcomString (see GCValue).
 
 */
@interface GCString : GCValue

@end

/**
 
 A Gedcom name string value. Provides a surname, firstname displayString for name values.
 
 */
@interface GCNamestring : GCString

@end

/**
 
 A Gedcom place string value. Provides a hierarchy of places; upon creation, places are split into jurisdictions on commas, in order of lowest to highest, as per the Gedcom spec. Thus, ordering by places will order by the highest juridiction first, then lower as necessary.
 
 */
@interface GCPlacestring : GCString

/// Returns the root-level place.
+ (instancetype)rootPlace;

/// The name of the place string.
@property (readonly) NSString *name;

/// The jurisdiction containing the place.
@property (readonly) GCPlacestring *superPlace;

/// The sub-locations within the given place.
@property (readonly) NSDictionary *subPlaces;

@end

/**
 
 GCValue subclass to handle lists of string values.
 
 */
@interface GCList : GCValue

/** Initializes and returns a list with the specified elements.
 
 @param elements A collection of elements.
 @return A new list.
 */
- (instancetype)initWithElements:(NSArray *)elements;

/// Returns an array of the elements in the list.
@property (readonly) NSArray *elements;

@end

/**
 
 A Gedcom numeric value.
 
 */
@interface GCNumber : GCValue

/// The receiver's value as an NSNumber.
@property (readonly) NSNumber *numberValue;

@end

/**
 
 A Gedcom gender value.
 
 Note that Gedcom only has support for three types of gender.
 
 */
@interface GCGender : GCValue

/** Returns a singleton instance representing the male gender.
 
 @return A singleton instance representing the male gender.
 */
+ (instancetype)maleGender;

/** Returns a singleton instance representing the female gender.
 
 @return A singleton instance representing the female gender.
 */
+ (instancetype)femaleGender;

/** Returns a singleton instance representing an unknown gender.
 
 @return A singleton instance representing an unknown gender.
 */
+ (instancetype)unknownGender;

@end

/**
 
 A Gedcom boolean value. Note that there is no explicit "false" in the Gedcom specification, only yes(true) and undecided.
 
 */
@interface GCBool : GCValue

/** Returns a singleton instance representing a true value.
 
 @return A singleton instance representing a true value.
 */
+ (instancetype)yes;

/** Returns a singleton instance representing an undecided value.
 
 @return A singleton instance representing an undecided value.
 */
+ (instancetype)undecided;

/// The receiver's value as a BOOL.
@property (readonly) BOOL boolValue;

@end

@class GCDate;

/**
 
 Gedcom ages can have many forms. This class cluster provides parsing, sorting, and a helper method for calculating ages.
 
 */
@interface GCAge : GCValue

#pragma mark Helpers

/// @name Helpers

/** Calculates and returns an age created by subtracting the earliest of `toDate` and `fromDate` from the latest. In other words, the absolute number of years, months, & days between the days.
 
 Useful for example for calculating how old an individual was on a given date.
 
 @param fromDate A GCDate object.
 @param toDate A GCDate object.
 @return A new age.
 */
+ (instancetype)ageFromDate:(GCDate *)fromDate toDate:(GCDate *)toDate;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The years part of the age.
@property (readonly) NSUInteger years;

/// The months part of the age.
@property (readonly) NSUInteger months;

/// The days part of the age.
@property (readonly) NSUInteger days;

/// An approximate sum of the days, ie (365*years) + (30*months) + days.
@property (readonly) NSUInteger totalDays;

@end

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
+ (instancetype)dateWithDate:(NSDate *)date;

#pragma mark Helpers
/// @name Helpers

/** Returns a date created by adding the given age to the receiver.
 
 @param age A GCAge object.
 @return A new date.
 */
- (instancetype)dateByAddingAge:(GCAge *)age;

/** Returns a date created by subtracting the given age to the receiver.
 
 @param age A GCAge object.
 @return A new date.
 */
- (instancetype)dateBySubtractingAge:(GCAge *)age;

/** Returns a boolean value indicating whether the given date is contained within the receiver.
 
 If the date is larger than receiver's minDate and less than receiver's maxDate, the result is NO.
 
 @param date an NSDate object.
 @return `YES` if date is contained in the receiver, otherwise `NO`.
 */
- (BOOL)containsDate:(NSDate *)date;

#pragma mark Objective-C properties

/// @name Helpers

/// The calendar used by the receiver.
@property (readonly) NSCalendar *calendar;

/// If the date is a range or a period, will return the start of the period (or nil for open-ended), otherwise it will be the same as the date, and identical to maxDate.
@property (readonly) NSDate *minDate;

/// If the date is a range or a period, will return the end of the period, otherwise it will be the same as the date, and identical to minDate.
@property (readonly) NSDate *maxDate;

@end

/**
 
 Abstract value formatter class. Use one of the subclasses instead:
 
 GCStringFormatter,
 GCListFormatter,
 GCNumberFormatter,
 GCGenderFormatter,
 GCAgeFormatter,
 GCDateFormatter, or
 GCBoolFormatter.
 
 */
@interface GCValueFormatter : NSFormatter

@property (nonatomic) BOOL displayFullString; // defaults to YES.

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom strings and vice versa. See GCString.
@interface GCStringFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom lists and vice versa. See GCList.
@interface GCListFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom numbers and vice versa. See GCNumber.
@interface GCNumberFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom genders and vice versa. See GCGender.
@interface GCGenderFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom ages and vice versa. See GCAge.
@interface GCAgeFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom dates and vice versa. See GCDate.
@interface GCDateFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom bools and vice versa. See GCBool.
@interface GCBoolFormatter : GCValueFormatter

@end