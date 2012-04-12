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

- (void)addProperty:(GCProperty *)property
{
    [self setValue:property forKey:[property type]];
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
        id obj = [self valueForKey:propertyName];
        
        if (obj) {
            if ([obj isKindOfClass:[GCMutableOrderedSetProxy class]]) {
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

#pragma mark NSKeyValueCoding overrides

- (id)valueForKey:(NSString *)key
{
    if ([[self validProperties] containsObject:key]) {
        id obj = [_properties objectForKey:key];
        
        if ([self allowsMultiplePropertiesOfType:key] && obj == nil) {
            //return a fresh proxy that will act when added to/removed from.
            obj = [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:[NSMutableOrderedSet orderedSet]
                                                                     addBlock:^(id obj) {
                                                                         [obj setDescribedObject:self];
                                                                     }
                                                                  removeBlock:^(id obj) {
                                                                      [obj setDescribedObject:nil];
                                                                  }];
            [_properties setObject:obj forKey:key];
        }
        
        return obj;
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
        if ([self allowsMultiplePropertiesOfType:key]) {
            id existing = [self valueForKey:key];
            
            if (existing) {
                //already have an array, so just add here:
                [existing addObject:value];
            } else {
                //create array:
                NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithObject:value];
                [_properties setObject:[[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:set
                                                                                          addBlock:^(id obj) {
                                                                                              [obj setDescribedObject:self];
                                                                                          }
                                                                                       removeBlock:^(id obj) {
                                                                                           [obj setDescribedObject:nil];
                                                                                       }]
                                forKey:key];
            }
        } else {
            [_properties setObject:value forKey:key];
        }
        [value setDescribedObject:self];
    } else {
        [super setValue:value forKey:key];
    }
}

#pragma mark Cocoa properties

- (NSString *)type
{
    return [_tag name];
}

- (NSArray *)properties
{
	NSMutableArray *properties = [NSMutableArray arrayWithCapacity:3];
	
	for (id property in [_properties allValues]) {
		if ([property respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
            for (id p in property) {
                [properties addObjectsFromArray:p];
            }
		} else {
			[properties addObject:property];
		}
	}
	
	return [properties copy];
}

- (NSArray *)attributes
{
	NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:3];
	
	for (id property in [self properties]) {
		if ([property isKindOfClass:[GCAttribute class]]) {
			[attributes addObject:property];
		}
	}
	
	return [attributes copy];
}

- (NSArray *)relationships
{
	NSMutableArray *relationships = [NSMutableArray arrayWithCapacity:3];
	
	for (id property in [self properties]) {
		if ([property isKindOfClass:[GCRelationship class]]) {
			[relationships addObject:property];
		}
	}
	
	return [relationships copy];
}

@synthesize gedTag = _tag;

@dynamic context;

@end
