//
//  GCTagAccessAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

#import "GCEntity.h"
#import "GCRecord.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

@interface GCObject (GCGedcomPropertyAdditions)

/// The GCTag corresponding to the receiver's class.
+ (GCTag *)gedTag;
@property (nonatomic, readonly) GCTag *gedTag;

+ (Class)objectClassWithType:(NSString *)type;

+ (NSArray *)rootClasses;

/// Returns an ordered collection of valid property types for the receiver.
@property (readonly) NSOrderedSet *validPropertyTypes;

/** Returns a struct with the minimum and maximum allowed occurrences of a given type of property.
 
 GCAllowedOccurrences is a { `min`, `max` } struct of two NSIntegers
 
 @param type A given type.
 @return A GCAllowedOccurrences struct.
 */
+ (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type;
- (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type;

/** A helper method for quicker lookups when only interested in knowing whether the receiver allows more than one of a given property type.
 
 @param type A property type.
 @return a `BOOL` indicating whether multiple properties of the given type are allowed.
 */
+ (BOOL)allowsMultipleOccurrencesOfPropertyType:(NSString *)type;
- (BOOL)allowsMultipleOccurrencesOfPropertyType:(NSString *)type;

/** Returns an array of the names of properties of a certain group, such as an individuals `individualEvent`s.
 
 @param groupName The name of a group.
 @return An array of property names or `nil` if there is no such group.
 */
+ (NSArray *)propertyTypesInGroup:(NSString *)groupName;
- (NSArray *)propertyTypesInGroup:(NSString *)groupName;

+ (NSString *)gedcomCode;
@property (nonatomic, readonly) NSString *gedcomCode;

/// The type of the receiver.
+ (NSString *)type;
@property (nonatomic, readonly) NSString *type;

/// The localized type of the receiver.
+ (NSString *)localizedType;
@property (nonatomic, readonly) NSString *localizedType;

/// The localized type of the receiver.
+ (NSString *)pluralType;
@property (nonatomic, readonly) NSString *pluralType;

@end

@interface GCEntity (GCTagAccessAdditions)

@property (nonatomic, readonly) BOOL takesValue;

@end

@interface GCAttribute (GCTagAccessAdditions)

/// The type of GCValue this attribute accepts.
@property (nonatomic, readonly) Class valueType;

@property (nonatomic, readonly) NSArray *allowedValues;

@property (nonatomic, readonly) BOOL allowsNilValue;

@end

@interface GCRelationship (GCTagAccessAdditions)

/// The type of GCRecord this relationship can point to.
@property (nonatomic, readonly) Class targetType;

@end
