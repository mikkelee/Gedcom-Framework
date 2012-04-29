//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCValue.h"

@class GCContext;
@class GCNode;
@class GCTag;
@class GCProperty;

/**
 
 Abstract object. Subclasses are GCHeader, GCEntity and GCProperty.
 
 */
@interface GCObject : NSObject

#pragma mark Initialization

/// @name Creating and initializing objects

/** Initializes and returns an object with the specified type.
 
 @param type A given type.
 @return A new object.
 */
- (id)initWithType:(NSString *)type;

#pragma mark GCProperty access

/// @name Accessing GCProperties

/// An ordered collection of valid property types for the receiver.
- (NSOrderedSet *)validProperties;

/** Returns a boolean indicating whether the receiver accepts multiple properties of a given type.
 
 @param type A given type.
 @return `YES` if the receiver allows multiple properties of the given type, otherwise `NO`.
 */
- (BOOL)allowsMultiplePropertiesOfType:(NSString *)type;

/** Adds the given property to the receiver's collection of properties.
 
 The property's type must be in the receiver's validProperties.
 
 If the receiver allows multiple properties of that type, it will add it to its collection, otherwise the property will override the previous property of that type.
 
 The property's describedObject is updated to reflect the receiver.
 
 @param property A given property.
 */
- (void)addProperty:(GCProperty *)property;

/** Removes the given property to the receiver's collection of properties.
 
 The property's describedObject is set to `nil`.
 
 @param property A given property.
 */
- (void)removeProperty:(GCProperty *)property;

#pragma mark Gedcom access

/// @name Gedcom access

/// The properties of the receiver as a collection of nodes.
/// @see GCNode
- (NSOrderedSet *)subNodes;

#pragma mark Comparison

/// @name Comparing objects

/** Compares the receiver to another GCObject.
 
 @param other A GCObject object.
 @return `NSOrderedAscending` if the receiver is earlier than other, `NSOrderedDescending` if the receiver is later than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

#pragma mark Equality

/** Compares the receiver and another GCObject intepreted as Gedcom strings.
 
 @param other A GCObject object.
 @return `YES` if the strings are identical, otherwise `NO`.
 */
- (BOOL)isEqualTo:(id)other;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The type of the receiver.
@property (readonly) NSString *type;

/// An ordered collection of all properties on the receiver.
@property NSMutableOrderedSet *properties;

/// An ordered collection of the receiver's attributes.
@property (readonly) NSMutableOrderedSet *attributes;

/// An ordered collection of the receiver's relationships.
@property (readonly) NSMutableOrderedSet *relationships;

/// The GCTag corresponding to the receiver's type.
@property (readonly) GCTag *gedTag;

/// The receiver as a GCNode.
@property (readonly) GCNode *gedcomNode;

/** The reeciver as a string of Gedcom data.
 
 Setting this property will cause the receiver to interpret the Gedcom data and add new properties and remove those that no longer exist.
 
 */
@property NSString *gedcomString;

/// The context associated with the receiver. Properties will forward the request to their describedObject.
@property (readonly) GCContext *context;

@end

@class GCEntity;
@class GCAge;
@class GCDate;

@interface GCObject (GCConvenienceMethods)

/// @name Accessing GCProperties

/** Creates a GCAttribute with the given type and value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type value:(GCValue *)value;

/** Creates a GCAttribute with the given type and string value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type stringValue:(NSString *)value;

/** Creates a GCAttribute with the given type and numeric value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type numberValue:(NSNumber *)value;

/** Creates a GCAttribute with the given type and age value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type ageValue:(GCAge *)value;

/** Creates a GCAttribute with the given type and boolean value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type boolValue:(BOOL)value;

/** Creates a GCAttribute with the given type and date value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type dateValue:(GCDate *)value;

/** Creates a GCAttribute with the given type and gender value and adds it to the receiver via addProperty:
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type genderValue:(GCGender)value;

/** Creates a GCRelationship with the given type and target and adds it to the receiver via addProperty:
 
 @param type The type of the relationship.
 @param target The target of the relationship.
 */
- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target;

/** Creates a GCProperty based on the node and adds it to the receiver via addProperty:
 
 @param node A node.
 */
- (void)addPropertyWithGedcomNode:(GCNode *)node;

@end
