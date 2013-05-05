//
//  GCObject+GCKeyValueAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

@class GCValue;
@class GCEntity;

@interface GCObject (GCKeyValueAdditions)

#pragma mark Keyed subscript accessors

/** Returns the property/ies with the given type. Used like on NSMutableDictionary.
 
 @param key The type of the property.
 @return If the property allows multiple occurrences, will return a KVC-compliant NSMutableArray, otherwise the property itself.
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/** Sets the property for the given type. Used like on NSMutableDictionary
 
 @param object An array for properties allowing multiple occurrences, otherwise a single property.
 @param key The type of the property.
 */
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

@end

@interface GCObject (GCMoreConvenienceMethods)

/// @name Accessing GCProperties

/** Creates a GCAttribute with the given type and value and adds it to the receiver via Key-Value coding.
 
 @param type The type of the attribute.
 @param value The value of the attribute. If the value is not a GCValue, one will be created.
 */
- (void)addAttributeWithType:(NSString *)type value:(id)value;

/** Creates a one or more GCAttributes with the given type and value(s) and adds them to the receiver via addAttributeWithType:value:.
 
 @param type The type of the attribute.
 @param values An array of values.
 */
- (void)addAttributeWithType:(NSString *)type valuesFromArray:(NSArray *)values;

/** Creates a one or more GCAttributes with the given type and value(s) and adds them to the receiver via addAttributeWithType:value:.
 
 @param type The type of the attribute.
 @param values A nil-terminated list of values.
 */
- (void)addAttributeWithType:(NSString *)type values:(id)firstValue, ... NS_REQUIRES_NIL_TERMINATION;

/** Creates a GCRelationship with the given type and target and adds it to the receiver via Key-Value coding.
 
 @param type The type of the relationship.
 @param target The target of the relationship.
 */
- (void)addRelationshipWithType:(NSString *)type target:(GCRecord *)target;

@end