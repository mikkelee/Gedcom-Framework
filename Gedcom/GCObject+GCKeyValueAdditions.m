//
//  GCObject+GCKeyValueAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

#import "GCEntity.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"
#import "GCValue.h"

#import "GCObject+GCConvenienceMethods.h"
#import "GCObject+GCKeyValueAdditions.h"

@implementation GCObject (GCKeyValueAdditions)

#pragma mark NSKeyValueCoding overrides

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[GCValue class]] && ([self.validPropertyTypes containsObject:key] || [GCTag tagNamed:key].isCustom)) {
        [self addAttributeWithType:key value:value];
    } else if ([value isKindOfClass:[GCEntity class]] && ([self.validPropertyTypes containsObject:key] || [GCTag tagNamed:key].isCustom)) {
        [self addRelationshipWithType:key target:value];
    } else if ([value isKindOfClass:[NSArray class]] && ([self.validPropertyTypes containsObject:key] || [GCTag tagNamed:key].isCustom)) {
        for (id item in value) {
            [self setValue:item forKey:key];
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), key);
    if ([key hasSuffix:@"@primary"]) {
        NSString *cleanKey = [key componentsSeparatedByString:@"@"][0];
        
        if ([[super valueForKey:cleanKey] count] > 0) {
            return [super valueForKey:cleanKey][0];
        } else {
            return nil;
        }
    } else if ([[self propertyTypesInGroup:key] count] > 0) {
        NSMutableArray *values = [NSMutableArray array];
        
        for (NSString *propertyType in [self propertyTypesInGroup:key]) {
            [values addObjectsFromArray:[super valueForKey:propertyType]];
        }
        
        return values;
    } else {
        return [super valueForUndefinedKey:key];
    }
}

#pragma mark Subscript accessors

- (id)objectForKeyedSubscript:(id)key
{
    return [super valueForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key
{
    return [self setValue:object forKey:(NSString *)key];
}

#pragma mark NSKeyValueObserving overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    [keyPaths addObject:@"attributedGedcomString"];
    [keyPaths addObject:@"gedcomString"];
    [keyPaths addObject:@"gedcomNode"];
    [keyPaths addObject:@"properties"];
    [keyPaths addObject:@"mutableProperties"];
    
    GCTag *tag = [GCTag tagNamed:key];
    
    if ([key isEqualToString:@"properties"]) {
        NSString *cleanName = [[self className] substringFromIndex:2];
        
        if ([cleanName hasSuffix:@"Entity"])
            cleanName = [cleanName substringToIndex:[cleanName length] - 6];
        if ([cleanName hasSuffix:@"Attribute"])
            cleanName = [cleanName substringToIndex:[cleanName length] - 9];
        if ([cleanName hasSuffix:@"Relationship"])
            cleanName = [cleanName substringToIndex:[cleanName length] - 12];
        
        //NSLog(@"cleanName: %@", cleanName);
        
        tag = [GCTag tagNamed:[NSString stringWithFormat:@"%@%@", [[cleanName substringToIndex:1] lowercaseString], [cleanName substringFromIndex:1]]];
    }
    
    if (tag != nil) {
        for (GCTag *subTag in tag.validSubTags) {
            [keyPaths addObject:subTag.name];
            /*
             GCTag *subSubTag = subTag;
             while ([[subSubTag validSubTags] count] > 0) {
             for (GCTag *subSubSubTag in [subSubTag validSubTags]) {
             
             }
             }*/
        }
    }
    
    [keyPaths removeObject:key];
    
    //NSLog(@"keyPaths on %@: %@ => %@", [self className], key, keyPaths);
    
    return keyPaths;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"gedcomNode"] || [key isEqualToString:@"gedcomString"] || [key isEqualToString:@"attributedGedcomString"]) {
        return NO;
    } else {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

@end

@implementation GCObject (GCMoreConvenienceMethods)

- (void)addAttributeWithType:(NSString *)type value:(id)value
{
    GCTag *tag = [GCTag tagNamed:type];
    
    GCValue *val = nil;
    if ([value isKindOfClass:[GCValue class]]) {
        val = value;
    } else {
        val = [[tag.valueType alloc] initWithGedcomStringValue:value];
    }
    
    GCAttribute *attr = [[tag.objectClass alloc] initWithValue:val];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] addObject:attr];
    } else {
        [self setValue:attr forKey:tag.name];
    }
}

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target
{
    GCTag *tag = [GCTag tagNamed:type];
    
    GCRelationship *rel = [[tag.objectClass alloc] init];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] addObject:rel];
    } else {
        [self setValue:rel forKey:tag.name];
    }
    
    rel.target = target;
}

@end