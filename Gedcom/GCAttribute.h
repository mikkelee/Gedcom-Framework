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

- (void)setValueWithGedcomString:(NSString *)string;

@end

@interface GCAttribute (GCConvenienceMethods)

/// @name Creating attributes
/** Returns an attribute with the specified type and value.
 
 @param type The type of the attribute.
 @param value A GCValue.
 @return A new attribute.
 
 */
+ (id)attributeWithType:(NSString *)type value:(GCValue *)value;

@end
