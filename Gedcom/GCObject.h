//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GedcomTypedefs.h"

@class GCContext;
@class GCNode;
@class GCProperty;
@class GCTag;

/**
 
 Abstract object. Subclasses are GCHeader, GCEntity and GCProperty.
 
 */
@interface GCObject : NSObject <NSCoding>

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
@property (nonatomic, readonly) NSString *type;

/// The localized type of the receiver.
@property (nonatomic, readonly) NSString *localizedType;

/// The GCTag corresponding to the receiver's type.
@property (nonatomic, readonly) GCTag *gedTag;

/// The root object of a given tree of GCObjects. Will usually be a GCRecord or a GCEntity, but may be for instance a GCAttribute if it isn't attached to an entity.
@property (nonatomic, readonly) GCObject *rootObject;

/// The context associated with the receiver. Properties will forward the request to their describedObject.
@property (nonatomic, readonly, weak) GCContext *context;

/** The value of the receiver appropiate for displaying in the user interface.
 
 For records, it will be their xref; for attributes, their value; and for relationships, the target's xref.
 
 */
@property (nonatomic, readonly) NSString *displayValue;

/// The displayValue of the receiver, with attributes.
@property (nonatomic, readonly) NSAttributedString *attributedDisplayValue;

#pragma mark Accessing Gedcom output
/// @name Accessing Gedcom output

/// The receiver as a GCNode.  Setting this property will cause the receiver to interpret the node and add new properties and remove those that no longer exist.
@property (nonatomic) GCNode *gedcomNode;

/// The properties of the receiver as a collection of nodes. @see GCNode
@property (nonatomic, readonly) NSArray *subNodes;

/// The receiver as a string of Gedcom data. Setting it will interpret the string as a GCNode and set it to the receiver's gedcomNode property.
@property (nonatomic) NSString *gedcomString;

/// The receiver as an attributed string of Gedcom data.
@property (nonatomic) NSAttributedString *attributedGedcomString;

#pragma mark Accessing properties

/// The properties of the receiver ordered as indicated in the spec.
@property (nonatomic, readonly) NSArray *properties;

/// The properties of the receiver as a KVC-compliant mutable set.
@property (readonly, nonatomic) NSMutableArray *mutableProperties;

/// The non-standard properties of the receiver, if any.
@property (nonatomic, readonly) NSArray *customProperties;

@property (nonatomic, readonly) NSMutableArray *mutableCustomProperties;

@property (nonatomic, readonly) NSURL *URL;

@end

@interface GCObject (GCHelperAdditions)

+ (GCTag *)gedTag;

@end
