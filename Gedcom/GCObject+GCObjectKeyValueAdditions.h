//
//  GCObject+GCObjectKeyValueAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

@class GCValue;
@class GCEntity;

@interface GCObject (GCObjectKeyValueAdditions)

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

/// The properties of the receiver as a KVC-compliant mutable set.
@property (readonly, nonatomic) NSMutableSet *allProperties;

@end

@interface GCObject (GCMoreConvenienceMethods)

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

@end