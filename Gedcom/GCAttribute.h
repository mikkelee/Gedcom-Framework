//
//  GCAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

@class GCValue;

/**
 
 Attributes are properties that describe a key/value pair on another GCObject. For example, a person's name or the date of an event are attributes.
 
 In the first example, the attribute's type would be "personalName", and the value would be a GCNamestring containing the name. The attribute can then have further properties, such as a nickname, or source references.
 
 In the latter, the type would be "date", and the value would be a GCDate.
 
 */
@interface GCAttribute : GCProperty

#pragma mark Objective-C properties

/// @name Accessing values
/** The GCValue of the attribute.
 
 May be nil.
 
 */
@property (nonatomic) GCValue *value;

@end

@interface GCAttribute (GCConvenienceMethods)

/// @name Creating attributes
/** Returns an attribute with the specified value.
 
 @param value A GCValue.
 @return A new attribute.
 
 */
- (instancetype)initWithValue:(GCValue *)value;

/** Returns an attribute with the specified value.
 
 The appropiate GCValue subclass will be created.
 
 @param value An NSString.
 @return A new attribute.
 
 */
- (instancetype)initWithGedcomStringValue:(NSString *)value;

/// @name Accessing values
/** Convenience method for setting the attribute's value with a given string.
 
 The attribute will create an appropiate GCValue subclass object.
 
 @param string The string value to use.
 */
- (void)setValueWithGedcomString:(NSString *)string;

@end

@interface GCAttribute (GCGedcomAccessAdditions)

@property (nonatomic, readonly) Class valueType;

@end
