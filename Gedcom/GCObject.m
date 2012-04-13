//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCContext.h"

#import "GCEntity.h"
#import "GCHeader.h"
#import "GCTrailer.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCMutableOrderedSetProxy.h"

@interface GCObject () 

@end

@implementation GCObject {
    NSMutableDictionary *_properties;
}

#pragma mark Initialization

- (id)initWithType:(NSString *)type
{
    self = [super init];
    
    if (self) {
        _tag = [GCTag tagNamed:type];
        _properties = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    return self;    
}

#pragma mark GCProperty access

- (void)addProperty:(GCProperty *)property
{
    NSParameterAssert([property isKindOfClass:[GCProperty class]]);
    
    if ([property describedObject]) {
        [[property describedObject] removeProperty:property];
    }
    
    if ([self allowsMultiplePropertiesOfType:[property type]]) {
        id existing = [_properties valueForKey:[property type]];
        
        if (existing) {
            //already have an set, so just add here:
            [existing addObject:property];
        } else {
            //create set:
            [_properties setObject:[NSMutableOrderedSet orderedSetWithObject:property]
                            forKey:[property type]];
        }
    } else {
        [self removeProperty:[_properties valueForKey:[property type]]];
        [_properties setObject:property forKey:[property type]];
    }
    
    [property setDescribedObject:self];
}

- (void)removeProperty:(GCProperty *)property
{
    if (property == nil) {
        return;
    }
    
    NSParameterAssert([property isKindOfClass:[GCProperty class]]);
    NSParameterAssert([property describedObject] == self);
    
    if ([self allowsMultiplePropertiesOfType:[property type]]) {
        [[_properties valueForKey:[property type]] removeObject:property];
    } else {
        [_properties removeObjectForKey:[property type]];
    }
    
    [property setDescribedObject:nil];
}

- (void)addAttributeWithType:(NSString *)type value:(GCValue *)value
{
    [self addProperty:[GCAttribute attributeWithType:type value:value]];
}

- (void)addAttributeWithType:(NSString *)type stringValue:(NSString *)value
{
    [self addProperty:[GCAttribute attributeWithType:type stringValue:value]];
}

- (void)addAttributeWithType:(NSString *)type numberValue:(NSNumber *)value
{
    [self addProperty:[GCAttribute attributeWithType:type numberValue:value]];
}

- (void)addAttributeWithType:(NSString *)type ageValue:(GCAge *)value
{
    [self addProperty:[GCAttribute attributeWithType:type ageValue:value]];
}

- (void)addAttributeWithType:(NSString *)type boolValue:(BOOL)value
{
    [self addProperty:[GCAttribute attributeWithType:type boolValue:value]];
}

- (void)addAttributeWithType:(NSString *)type dateValue:(GCDate *)value
{
    [self addProperty:[GCAttribute attributeWithType:type dateValue:value]];
}

- (void)addAttributeWithType:(NSString *)type genderValue:(GCGender)value
{
	[self addProperty:[GCAttribute attributeWithType:type genderValue:value]];
}

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target
{
	GCRelationship *relationship = [GCRelationship relationshipWithType:type target:target];
	
	[self addProperty:relationship];
    
	if ([[relationship gedTag] reverseRelationshipTag]) {
		BOOL relationshipExists = NO;
		for (GCRelationship *relationship in [target relationships]) {
			if ([[relationship target] isEqual:self]) {
				relationshipExists = YES;
			}
		}
		if (!relationshipExists) {
			[target addRelationshipWithType:[[[relationship gedTag] reverseRelationshipTag] name] 
									 target:(GCEntity *)self];
		}
	}
}

- (NSOrderedSet *)validProperties
{
	NSMutableOrderedSet *valid = [NSMutableOrderedSet orderedSetWithCapacity:[[_tag validSubTags] count]];
	
	for (id subTag in [_tag validSubTags]) {
		[valid addObject:[subTag name]];
	}
	
	return valid;
}

- (BOOL)allowsMultiplePropertiesOfType:(NSString *)type
{
	return [[GCTag tagNamed:[self type]] allowsMultipleSubtags:[GCTag tagNamed:type]];
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForKey:(NSString *)key
{
    if ([[self validProperties] containsObject:key]) {
        id obj = [_properties objectForKey:key];
        
        if ([self allowsMultiplePropertiesOfType:key]) {
            if (obj == nil) {
                obj = [NSMutableOrderedSet orderedSet];
            }
            //return a fresh proxy that will act when added to/removed from.
            return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:obj
                                                                      addBlock:^(id obj) {
                                                                          [self addProperty:obj];
                                                                      }
                                                                   removeBlock:^(id obj) {
                                                                       [self removeProperty:obj];
                                                                   }];
        } else {
            return obj;
        }
    } else {
        return [super valueForKey:key];
    }
}

- (void)setNilValueForKey:(NSString *)key
{
    [_properties removeObjectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([[self validProperties] containsObject:key] && [value isKindOfClass:[GCProperty class]]) {
        //TODO
    } else {
        [super setValue:value forKey:key];
    }
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (NSArray *)subNodes
{
    NSMutableArray *subNodes = [NSMutableArray arrayWithCapacity:3];
    
    for (NSString *propertyName in [self validProperties]) {
        id obj = [_properties valueForKey:propertyName];
        
        if (obj) {
            if ([obj isKindOfClass:[NSOrderedSet class]]) {
                NSArray *sorted = [obj sortedArrayUsingComparator:^(id obj1, id obj2) {
                    return [[obj1 stringValue] compare:[obj2 stringValue]];
                }];
                for (GCProperty *subObj in sorted) {
                    [subNodes addObject:[subObj gedcomNode]];
                }
            } else {
                [subNodes addObject:[obj gedcomNode]];
            }
        }
    }
	
	return subNodes;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (type: %@)", [super description], [self type]];
}

#pragma mark Cocoa properties

- (NSString *)type
{
    return [_tag name];
}

- (id)properties
{
	NSMutableOrderedSet *properties = [NSMutableOrderedSet orderedSet];
	
	for (id property in [_properties allValues]) {
		if ([property respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
            for (id p in property) {
                [properties addObject:p];
            }
		} else {
			[properties addObject:property];
		}
	}
	
	return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:properties
                                                              addBlock:^(id obj) {
                                                                  [self addProperty:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeProperty:obj];
                                                           }];
}

- (void)setProperties:(NSMutableOrderedSet *)properties
{
    //TODO
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (id)attributes
{
	NSMutableOrderedSet *attributes = [NSMutableOrderedSet orderedSet];
	
	for (id property in [self properties]) {
		if ([property isKindOfClass:[GCAttribute class]]) {
			[attributes addObject:property];
		}
	}
	
	return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:attributes
                                                              addBlock:^(id obj) {
                                                                  [self addProperty:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeProperty:obj];
                                                           }];
}

- (void)setAttributes:(NSMutableOrderedSet *)attributes
{
    //TODO
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (id)relationships
{
	NSMutableOrderedSet *relationships = [NSMutableOrderedSet orderedSet];
	
	for (id property in [self properties]) {
		if ([property isKindOfClass:[GCRelationship class]]) {
			[relationships addObject:property];
		}
	}
	
	return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:relationships
                                                              addBlock:^(id obj) {
                                                                  [self addProperty:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeProperty:obj];
                                                           }];
}

- (void)setRelationships:(NSMutableOrderedSet *)relationships
{
    //TODO
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

@synthesize gedTag = _tag;

@dynamic context;

@end
