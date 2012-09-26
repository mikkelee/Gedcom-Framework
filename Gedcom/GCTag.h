//
//  GCTag.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

#import <Foundation/Foundation.h>

typedef struct {
    NSInteger min;
    NSInteger max;
} GCAllowedOccurrences;

/**
 
 Tags are immutable singleton instances that help mapping between GCNode and GCObject.
 
 A tag knows its Gedcom code, what subtags are allowed, what type value a property has, etc.
 
 */
@interface GCTag : NSObject <NSCopying, NSCoding>

#pragma mark Obtaining tags
/// @name Obtaining tags

/** Returns a tag with the given name.
 
 @param name The name of the requested tag.
 @return A tag or `nil` if none exists.
 */
+ (GCTag *)tagNamed:(NSString *)name;

/** Returns a root tag with the given code.
 
 @param code The code of the requested tag.
 @return A tag or `nil` if none exists.
 */
+ (GCTag *)rootTagWithCode:(NSString *)code;

#pragma mark Accessing subtags
/// @name Accessing subtags

/** Returns the subtag of the receiver with the given code and type. The type can be `attribute` or `relationship`.
 
 @param code The name of the requested subtag.
 @param type The type of the requested subtag.
 @return A tag or `nil` if none exists.
 */
- (GCTag *)subTagWithCode:(NSString *)code type:(NSString *)type;

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

- (BOOL)allowsMultipleOccurrencesOfSubTag:(GCTag *)tag;

#pragma mark - Objective-C properties -
#pragma mark Accessing properties
/// @name Accessing properties

/// The Gedcom code of the receiver.
@property (readonly, nonatomic) NSString *code;

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

#pragma mark Attribute tags
/// @name Attribute tags

/// A class indicating which type its value is. Will be `nil` if the tag is not an attribute-tag. See GCValue.
@property (readonly) Class valueType;

/// A collection of allowed values; will be empty if the tag is not an attribute-tag or there are no restrictions on values.
@property (readonly) NSArray *allowedValues;

#pragma mark Relationship tags
/// @name Relationship tags

/// A class indicating which type its target is. Will be `nil` if the tag is not a relationship-tag.
@property (readonly) Class targetType;

/// If the tag is a relationship-tag and the relationship is two-way (such as FAMC &lt;-&gt; CHIL) the reverse tag is provided. Can be `nil`.
@property (readonly, nonatomic) GCTag *reverseRelationshipTag;

@end
