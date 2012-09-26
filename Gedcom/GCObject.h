//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCTag.h"

@class GCContext;
@class GCNode;
@class GCProperty;

/**
 
 Abstract object. Subclasses are GCHeader, GCEntity and GCProperty.
 
 */
@interface GCObject : NSObject <NSCoding>

#pragma mark Initialization
/// @name Creating and initializing objects

/** Initializes and returns an object with the specified type.
 
 @param type A given type.
 @return A new object.
 */
- (id)initWithType:(NSString *)type;

#pragma mark Accessing GCProperties
/// @name Accessing GCProperties

/// Returns an ordered collection of valid property types for the receiver.
@property (readonly) NSOrderedSet *validPropertyTypes;

/** Returns a struct with the minimum and maximum allowed occurrences of a given type of property.
 
 GCAllowedOccurrences is a { `min`, `max` } struct of two NSIntegers
 
 @param type A given type.
 @return A GCAllowedOccurrences struct.
 */
- (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type;

/** Returns an array of the names of properties of a certain group, such as an individuals `individualEvent`s.
 
 @param groupName The name of a group.
 @return An array of property names or `nil` if there is no such group.
 */
- (NSArray *)propertyTypesInGroup:(NSString *)groupName;

#pragma mark Keyed subscript accessors

/** Returns the property/ies with the given type. Used like in NSMutableDictionary.
 
 @param key The type of the property.
 @return If the property allows multiple occurrences, will return a KVC-compliant NSMutableArray, otherwise the property itself.
 */
- (id)objectForKeyedSubscript:(id)key;

/** Sets the property for the given type. Used like in NSMutableDictionary
 
 @param object A collection for properties allowing multiple occurrences, otherwise a single property.
 @param key The type of the property.
 */
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key;

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

#pragma mark - Objective-C properties -

/// @name Accessing properties

/// The type of the receiver.
@property (readonly) NSString *type;

/// The localized type of the receiver.
@property (readonly) NSString *localizedType;

/// The GCTag corresponding to the receiver's type.
@property (readonly) GCTag *gedTag;

/// The root object of a given tree of GCObjects. Will usually be a GCEntity, but may be for instance a GCAttribute if it isn't attached to an entity.
@property (readonly, nonatomic) GCObject *rootObject;

/// The context associated with the receiver. Properties will forward the request to their describedObject.
@property (readonly, nonatomic) GCContext *context;

/** The value of the receiver appropiate for displaying in the user interface.
 
 For entities, it will be their xref; for attributes, their value; and for relationships, the target's xref.
 
 */
@property (readonly, nonatomic) NSString *displayValue;

/// The displayValue of the receiver, with attributes.
@property (readonly, nonatomic) NSAttributedString *attributedDisplayValue;

#pragma mark Accessing Gedcom output
/// @name Accessing Gedcom output

/// The receiver as a GCNode.  Setting this property will cause the receiver to interpret the node and add new properties and remove those that no longer exist.
@property GCNode *gedcomNode;

/// The properties of the receiver as a collection of nodes. @see GCNode
@property (readonly) NSArray *subNodes;

/// The receiver as a string of Gedcom data. Setting it will interpret the string as a GCNode and set it to the receiver's gedcomNode property.
@property NSString *gedcomString;

/// The receiver as an attributed string of Gedcom data.
@property NSAttributedString *attributedGedcomString;

@end

#pragma mark -

@class GCValue;
@class GCEntity;

@interface GCObject (GCConvenienceMethods)

/// @name Accessing GCProperties

/** Creates a GCAttribute with the given type and value and adds it to the receiver via Key-Value coding.
 
 @param type The type of the attribute.
 @param value The value of the attribute.
 */
- (void)addAttributeWithType:(NSString *)type value:(GCValue *)value;

/** Creates a GCRelationship with the given type and target and adds it to the receiver via Key-Value coding.
 
 @param type The type of the relationship.
 @param target The target of the relationship.
 */
- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target;

/** Creates a GCProperty based on the node and adds it to the receiver via Key-Value coding.
 
 @param node A node.
 */
- (void)addPropertyWithGedcomNode:(GCNode *)node;

/** Creates a collection of GCProperties based on the nodes and adds them to the receiver via Key-Value coding.
 
 @param nodes An array of nodes.
 */
- (void)addPropertiesWithGedcomNodes:(NSArray *)nodes;

/// The properties of the receiver as a KVC-compliant mutable array.
@property (readonly, nonatomic) NSMutableSet *allProperties;

@end

#pragma mark -

@interface GCObject (GCValidationMethods)

/// @name Validating objects

/** Returns whether the receiver is a valid Gedcom object.
 
 If the object is invalid, the error pointer will be updated with an NSError describing the problem.
 
 @param error A pointer to an NSError object
 @return `YES` if the object is valid, otherwise `NO`.
 */
- (BOOL)validateObject:(NSError **)error;

@end