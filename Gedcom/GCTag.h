//
//  GCTag.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GedcomTypedefs.h"

/**
 
 Tags are immutable singleton instances that help mapping between GCNode and GCObject.
 
 A tag knows its Gedcom code, what subtags are allowed, what type value a property has, etc.
 
 */
@interface GCTag : NSObject <NSCopying, NSCoding>

#pragma mark Obtaining tags
/// @name Obtaining tags

/** Returns the tag with the given name.
 
 @param name The name of the requested tag.
 @return A tag or `nil` if none exists.
 */
+ (GCTag *)tagNamed:(NSString *)name;

/** Returns the root tag with the given code.
 
 @param code The code of the requested tag.
 @return A tag or `nil` if none exists.
 */
+ (GCTag *)rootTagWithCode:(NSString *)code;

/** Returns the tag for the given class.
 
 @param aClass The class associated with the requested tag.
 @return A tag or `nil` if none exists.
 */
+ (GCTag *)tagWithObjectClass:(Class)aClass;

/** Returns an ordered collection of root tags.
 
 The tags will be ordered as per the specification.
 
 @return An array of tags.
 */
+ (NSArray *)rootTags;

#pragma mark Accessing subtags
/// @name Accessing subtags

/** Returns the subtag of the receiver with the given code and type. The type can be `attribute` or `relationship`.
 
 @param code The name of the requested subtag.
 @param type The type of the requested subtag.
 @return A tag or `nil` if none exists.
 */
- (GCTag *)subTagWithCode:(NSString *)code type:(GCTagType)type;

/** Returns the subtag of the receiver with the given name.
 
 @param name The name of the requested subtag.
 @return A tag or `nil` if none exists.
 */
- (GCTag *)subTagWithName:(NSString *)name;

/** Returns an array of the names of properties of a certain group, such as an individuals `individualEvent`s.
 
 @param groupName The name of a group.
 @return An array of tags or `nil` if there is no such group.
 */
- (NSArray *)subTagsInGroup:(NSString *)groupName;

/** Returns whether a given subtag is a valid subtag of the receiver.
 
 @param tag A GCTag object.
 @return `YES` if the given subtag is valid, otherwise `NO`.
 */
- (BOOL)isValidSubTag:(GCTag *)tag;

/** Returns a struct with the minimum and maximum allowed occurrences of a given subtag on the receiver.
 
 GCAllowedOccurrences is a { `min`, `max` } struct of two NSIntegers.
 
 * If the subtag is custom, the result will be { 0, NSIntegerMax }
 * If the subtag is not allowed, the result willb e { 0, 0 } //TOOD verify
 
 @param tag A GCTag object.
 @return A GCAllowedOccurrences struct.
 */
- (GCAllowedOccurrences)allowedOccurrencesOfSubTag:(GCTag *)tag;

/** A helper method for quicker lookups when only interested in knowing whether the receiver allows more than one of a given subtag.
 
 @param tag A GCTag object.
 @return a `BOOL` indicating whether multiple subtags of the given type are allowed.
 */
- (BOOL)allowsMultipleOccurrencesOfSubTag:(GCTag *)tag;

#pragma mark - Objective-C properties -
#pragma mark Accessing properties
/// @name Accessing properties

/// The Gedcom code of the receiver.
@property (readonly, nonatomic) NSString *code;

/// The type of the receiver.
@property (readonly, nonatomic) GCTagType type;

/// The human readable name of the receiver.
@property (readonly) NSString *name;

/// The human readable name of the receiver in plural.
@property (readonly, nonatomic) NSString *pluralName;

/// The localized name of the receiver.
@property (readonly, nonatomic) NSString *localizedName;

/// Returns whether the receiver is custom or not. Usually this is indicated by a leading underscore in its `code`.
@property (readonly, nonatomic) BOOL isCustom;

/// An ordered collection of valid subtags.
@property (readonly, nonatomic) NSOrderedSet *validSubTags;

/// The GCTag's corresponding GCObject subclass.
@property (readonly) Class objectClass;

#pragma mark Entity tags
/// @name Entity tags

/// A BOOL indicating whether the entity for the tag should have a value.
@property (readonly) BOOL takesValue;

#pragma mark Attribute tags
/// @name Attribute tags

/// A class indicating which type its value is. Will be `nil` if the tag is not an attribute-tag. See GCValue.
@property (readonly) Class valueType;

/// A BOOL indicating whether the tag allows nil values. If `NO` it must have a value.
@property (readonly) BOOL allowsNilValue;

/// A collection of allowed values; will be empty if the tag is not an attribute-tag or there are no restrictions on values.
@property (readonly) NSArray *allowedValues;

#pragma mark Relationship tags
/// @name Relationship tags

/// A class indicating which type its target is. Will be `nil` if the tag is not a relationship-tag.
@property (readonly) Class targetType;

/// A BOOL indicating whether the relationship has a reverse.
@property (readonly) BOOL hasReverse;

/// In the case of relationships which have a reverse, a BOOL indicating whether the relationship is the main one.
@property (readonly) BOOL isMain;

@end
