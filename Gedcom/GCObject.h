//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCContext;
@class GCNode;
@class GCTag;
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

#pragma mark GCProperty access

/// @name Accessing GCProperties

/// An ordered collection of valid property types for the receiver.
- (NSOrderedSet *)validProperties;

/** Returns a boolean indicating whether the receiver accepts multiple properties of a given type.
 
 @param type A given type.
 @return `YES` if the receiver allows multiple properties of the given type, otherwise `NO`.
 */
- (BOOL)allowsMultiplePropertiesOfType:(NSString *)type;

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

/// Returns whether the receiver can have properties itself.
@property (readonly) BOOL allowsProperties;

/// The GCTag corresponding to the receiver's type.
@property (readonly) GCTag *gedTag;

/// The receiver as a GCNode.  Setting this property will cause the receiver to interpret the node and add new properties and remove those that no longer exist.
@property GCNode *gedcomNode;

/// The reeciver as a string of Gedcom data. Setting it will interpret the string as a GCNode and set it to the receiver's gedcomNode property.
@property NSString *gedcomString;

/// The receiver as an attributed string of Gedcom data.
@property NSAttributedString *attributedGedcomString;

/// The context associated with the receiver. Properties will forward the request to their describedObject.
@property (readonly) GCContext *context;

/** The value of the receiver appropiate for displaying in the user interface.
 
 For entities, it will be their xref; for attributes, their value; and for relationships, the target's xref.

 */
@property (readonly) NSString *displayValue;

/// The displayValue of the receiver, with attributes.
@property (readonly) NSAttributedString *attributedDisplayValue;

@end

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
- (void)addPropertiesWithGedcomNodes:(NSOrderedSet *)nodes;

/// The properties of the receiver as a KVC-compliant mutable array. Functionally the same as calling -mutableArrayValueForKey:@"properties".
@property (readonly) NSMutableArray *allProperties;

@end

@interface GCObject (GCCodingHelpers)

//TODO should probably not be documented at all...

/// @name Internal methods

/** Used internally.
 
 @param aDecoder Used internally.
 */
- (void)decodeProperties:(NSCoder *)aDecoder;

/** Used internally.
 
 @param aCoder Used internally.
 */
- (void)encodeProperties:(NSCoder *)aCoder;

@end

@interface GCObject (GCValidationMethods)

/// @name Validating objects

/** Returns whether the receiver is a valid Gedcom object.
 
 If the object is invalid, the error pointer will be updated with an NSError describing the problem.
 
 @param error A pointer to an NSError object
 @return `YES` if the object is valid, otherwise `NO`.
 */
- (BOOL)validateObject:(NSError **)error;

@end