//
//  GCAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

@class GCValue;
@class GCAge;
@class GCDate;

/**
 
 Attributes are properties that describe a key/value pair on another GCObject. For example, a person's name or the date of an event are attributes.
 
 In the first example, the "key" of the attribute would be its type, "Name", and the "value" would be a GCValue with an NSString containing the name.
 
 In the latter, the "key" (type) would be "Date" and the "value" would be a GCValue containing a GCDate.
 
 */
@interface GCAttribute : GCProperty

#pragma mark Convenience constructors

/// @name Creating attributes
/** Returns an attribute whose type, value, and properties reflect the GCNode.
 
 @param object The object being described.
 @param node A GCNode. Its tag code must correspond to a valid property on the object.
 @return A new attribute.
 */
+ (id)attributeForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

/** Returns an attribute with a given type.
 
 The attribute's describedObject and value will be nil and must be set manually afterwards.
 
 @param type The type of the attribute.
 @return A new attribute.
 */
+ (id)attributeWithType:(NSString *)type;

#pragma mark Objective-C properties

/// @name Accessing values
/** The GCValue of the attribute.
 
 May be nil.
 
 */
@property GCValue *value;

@end

@interface GCAttribute (GCConvenienceMethods)

/// @name Creating attributes
/** Returns an attribute with the specified type and value.
 
 @param type The type of the attribute.
 @param value A GCValue.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type value:(GCValue *)value;

/** Returns an attribute with the specified type and string value.
 
 @param type The type of the attribute.
 @param value An NSString. Will be wrapped in a GCValue and set to the attribute's value.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type stringValue:(NSString *)value;

/** Returns an attribute with the specified type and numeric value.
 
 @param type The type of the attribute.
 @param value An NSNumber. Will be wrapped in a GCValue and set to the attribute's value.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type numberValue:(NSNumber *)value;

/** Returns an attribute with the specified type and age value.
 
 @param type The type of the attribute.
 @param value A GCAge. Will be wrapped in a GCValue and set to the attribute's value.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type ageValue:(GCAge *)value;

/** Returns an attribute with the specified type and date value.
 
 @param type The type of the attribute.
 @param value A GCDate. Will be wrapped in a GCValue and set to the attribute's value.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type dateValue:(GCDate *)value;

/** Returns an attribute with the specified type and boolean value.
 
 @param type The type of the attribute.
 @param value A `BOOL'. Will be wrapped in a GCValue and set to the attribute's value.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type boolValue:(BOOL)value;

/** Returns an attribute with the specified type and gender value.
 
 @param type The type of the attribute.
 @param value A GCGender. Will be wrapped in a GCValue and set to the attribute's value.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type genderValue:(GCGender)value;

/// @name Accessing values
/** The string value of the GCValue.
 
 Attempts coercing to NSString, see GCValue.
 
 */
@property NSString *stringValue;

/** The numeric value of the GCValue.
 
 Attempts coercing to NSNumber, see GCValue.
 
 */
@property NSNumber *numberValue;

/** The age value of the GCValue.
 
 Attempts coercing to GCAge, see GCValue.
 
 */
@property GCAge *ageValue;

/** The date value of the GCValue.
 
 Attempts coercing to GCDate, see GCValue.
 
 */
@property GCDate *dateValue;

/** The boolean value of the GCValue.
 
 Attempts coercing to BOOL, see GCValue.
 
 */
@property BOOL boolValue;

/** The gender value of the GCValue.
 
 Attempts coercing to GCGender, see GCValue.
 
 */
@property GCGender genderValue;

@end
