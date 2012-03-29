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
#import "GCHead.h"
#import "GCTrailer.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

@interface GCObject () 

@end

@implementation GCObject {
	GCContext *_context;
    NSMutableDictionary *_properties;
}

#pragma mark Initialization

- (id)initWithType:(NSString *)type inContext:(GCContext *)context
{
    self = [super init];
    
    if (self) {
        _tag = [GCTag tagNamed:type];
		_context = context;
        _properties = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    return self;    
}

#pragma mark Convenience constructors

+ (id)objectWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	if ([[node gedTag] objectClass] == [GCHead class]) {
		return [GCHead headWithGedcomNode:node inContext:context];
	} else if ([[node gedTag] objectClass] == [GCTrailer class]) {
		return [GCTrailer trailerWithGedcomNode:node inContext:context];
	} else if (![[node gedTag] isRoot]) {
		NSLog(@"Not a rootNode: %@", node); //TODO throw or something
		return nil;
	} else if ([[node gedTag] objectClass] == [GCEntity class]) {
		return [GCEntity entityWithGedcomNode:node inContext:context];
	} else {
		NSLog(@"Shouldn't happen! %@", node);
		return nil;
	}
}

#pragma mark GCProperty access

- (NSOrderedSet *)validProperties
{
	NSMutableOrderedSet *valid = [NSMutableOrderedSet orderedSetWithCapacity:[[_tag validSubTags] count]];
	
	for (id subTag in [_tag validSubTags]) {
		[valid addObject:[[GCTag tagCoded:subTag] name]];
	}
	
	return valid;
}

- (void)addProperty:(GCProperty *)property
{
    id key = [property type];
	
	//NSLog(@"self: %@ key: %@", self, key);
    
    NSParameterAssert([[self validProperties] containsObject:key]);
    
    id existing = [self valueForKey:key];
    
    BOOL allowsMultiple = true; //TODO
    
    if (allowsMultiple && existing) {
        //one exists already, so we get in array mode:
        
        if ([existing isKindOfClass:[NSMutableArray class]]) {
            //already have an array, so just add here:
            [existing addObject:property];
        } else {
            //create array and put both in:
            NSMutableArray *objects = [NSMutableArray arrayWithObjects:existing, property, nil];
            [self setValue:objects forKey:key];
        }
    } else {
        [self setValue:property forKey:key];
    }
}

- (void)addAttribute:(GCAttribute *)attribute
{
	[self addProperty:attribute];
}

- (void)addRelationship:(GCRelationship *)relationship
{
	[self addProperty:relationship];
}

- (void)addAttributeWithType:(NSString *)type stringValue:(NSString *)value
{
    [self addAttribute:[GCAttribute attributeForObject:self 
											  withType:type stringValue:value]];
}

- (void)addAttributeWithType:(NSString *)type numberValue:(NSNumber *)value
{
    [self addAttribute:[GCAttribute attributeForObject:self 
											  withType:type numberValue:value]];
}

- (void)addAttributeWithType:(NSString *)type ageValue:(GCAge *)value
{
    [self addAttribute:[GCAttribute attributeForObject:self 
											  withType:type ageValue:value]];
}

- (void)addAttributeWithType:(NSString *)type boolValue:(BOOL)value
{
    [self addAttribute:[GCAttribute attributeForObject:self 
											  withType:type boolValue:value]];
}

- (void)addAttributeWithType:(NSString *)type dateValue:(GCDate *)value
{
    [self addAttribute:[GCAttribute attributeForObject:self 
											  withType:type dateValue:value]];
}

- (void)addAttributeWithType:(NSString *)type genderValue:(GCGender)value
{
	[self addAttribute:[GCAttribute attributeForObject:self 
											  withType:type genderValue:value]];
}

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target
{
	GCRelationship *relationship = [GCRelationship relationshipForObject:self 
																withType:type target:target];
	
	[self addRelationship:relationship];
    
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
        //NSLog(@"property: %@", property);
        id obj = [self valueForKey:propertyName];
        
        if (obj) {
            //NSLog(@"obj: %@", obj);
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                NSArray *sorted = [obj sortedArrayUsingComparator:^(id obj1, id obj2) {
                    return [[obj1 stringValue] compare:[obj2 stringValue]];
                }];
                for (id subObj in sorted) {
                    //NSLog(@"subObj: %@", subObj);
                    [subNodes addObject:[subObj gedcomNode]];
                }
            } else {
                [subNodes addObject:[obj gedcomNode]];
            }
        }
    }
	
	return subNodes;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (type: %@)", [super description], [self type]];
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_properties objectForKey:key];
}

- (void)setNilValueForKey:(NSString *)key
{
    [_properties removeObjectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //TODO validity check (don't put a NAME on a FAM, etc)
    
    [_properties setObject:value forKey:key];
}

#pragma mark Properties

- (NSString *)type
{
    return [_tag name];
}

- (NSArray *)properties
{
	NSMutableArray *properties = [NSMutableArray arrayWithCapacity:3];
	
	for (id property in [_properties allValues]) {
		if ([property isKindOfClass:[NSArray class]]) {
			[properties addObjectsFromArray:property];
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

@synthesize context = _context;

@end
