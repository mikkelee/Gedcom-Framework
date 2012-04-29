//
//  GCValue.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GCUndefinedValue = -1,
    GCStringValue,
    GCNumberValue,
    GCAgeValue,
    GCDateValue,
    GCBoolValue,
    GCGenderValue
} GCValueType;

typedef enum {
	GCUnknownGender = -1,
	GCMale,
	GCFemale
} GCGender;

@class GCAge;
@class GCDate;

/**
 
 The value of an attribute. Can be either of the following types:
 
 `GCUndefinedValue`,
 `GCStringValue`,
 `GCNumberValue`,
 `GCAgeValue`,
 `GCDateValue`,
 `GCBoolValue`, or
 `GCGenderValue`.
 
 GCValue objects are immutable. To change the value of an attribute, assign a new value object to it.
 
 */
@interface GCValue : NSObject <NSCoding>

/// @name Creating and initializing values

/** Initializes and returns a value initialized with a given type and value.
 
 Booleans and genders must be wrapped in NSNumber
 
 @param type A GCValueType
 @param value An object containing the value. Its must correspond to the supplied type.
 @return A new value.
 */
- (id)initWithType:(GCValueType)type value:(id)value;

/// @name Comparing values

/** Compares the receiver to another GCValue.
 
 The exact comparison ... TODO
 
 @param other A GCValue object.
 @return `NSOrderedAscending` if the receiver is earlier than other, `NSOrderedDescending` if the receiver is later than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

/// @name Helpers

/** Returns the GCValueType with the given name.
 
 @param name A string.
 @return A GCValueType.
 */
+ (GCValueType)valueTypeNamed:(NSString *)name;

/// @name Accessing values

/// The receiver's value interpreted as a string.
@property (readonly) NSString *stringValue;

/// The receiver's value interpreted as a number.
@property (readonly) NSNumber *numberValue;

/// The receiver's value interpreted as a age.
@property (readonly) GCAge *ageValue;

/// The receiver's value interpreted as a date.
@property (readonly) GCDate *dateValue;

/// The receiver's value interpreted as a boolean.
@property (readonly) BOOL boolValue;

/// The receiver's value interpreted as a gender.
@property (readonly) GCGender genderValue;


@end

@interface GCValue (GCConvenienceMethods)

/// @name Creating and initializing values

/** Returns a value initialized with a given string.
  
 @param value An NSString object.
 @return A new value.
 */
+ (id)valueWithString:(NSString *)value;

/** Returns a value initialized with a given number.
 
 @param value An NSNumber object
 @return A new value.
 */
+ (id)valueWithNumber:(NSNumber *)value;

/** Returns a value initialized with a given age.
 
 @param value A GCAge object.
 @return A new value.
 */
+ (id)valueWithAge:(GCAge *)value;

/** Returns a value initialized with a given date.
 
 @param value A GCDate object.
 @return A new value.
 */
+ (id)valueWithDate:(GCDate *)value;

/** Returns a value initialized with a given Boolean.
 
 @param value A boolean.
 @return A new value.
 */
+ (id)valueWithBool:(BOOL)value;

/** Returns a value initialized with a given gender.
 
 @param value A GCGender (one of `GCMale`, `GCFemale`, or `GCUnknownGender`).
 @return A new value.
 */
+ (id)valueWithGender:(GCGender)value;

@end