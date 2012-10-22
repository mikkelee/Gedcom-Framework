//
//  GCObject+GCObjectKeyValueAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject+GCObjectKeyValueAdditions.h"

#import "GCObject_internal.h"

#import "GCEntity.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

@implementation GCObject (GCObjectKeyValueAdditions)

#pragma mark Internal helpers

- (void)_internalAddProperty:(GCProperty *)property
{
    if (property.describedObject && property.describedObject != self) {
        [property.describedObject.allProperties removeObject:property];
    }
    
    [property setValue:self forKey:@"describedObject"];
    
    if (property.gedTag.isCustom || self.gedTag.isCustom) {
        [(NSMutableArray *)self.customProperties addObject:property];
    } else if ([self _allowsMultipleOccurrencesOfPropertyType:property.type]) {
        NSString *key = property.gedTag.pluralName;
        
        NSIndexSet *indexes;
        
        if (![super valueForKey:key]) {
            [super setValue:[NSMutableArray array] forKey:key];
            indexes = [NSIndexSet indexSetWithIndex:0];
        } else {
            indexes = [NSIndexSet indexSetWithIndex:[[super valueForKey:key] count]];
        }
        
        [[super mutableArrayValueForKey:key] addObject:property];
    } else {
        [super setValue:property forKey:property.type];
    }
    
    GCParameterAssert(property.describedObject == self);
}

- (void)_internalRemoveProperty:(GCProperty *)property
{
    [property setValue:nil forKey:@"describedObject"];
    
   if (property.gedTag.isCustom || self.gedTag.isCustom) {
        [(NSMutableArray *)self.customProperties removeObject:property];
    } else if ([self _allowsMultipleOccurrencesOfPropertyType:property.type]) {
        NSString *key = property.gedTag.pluralName;
        
        [[super mutableArrayValueForKey:key] removeObject:property];
    } else {
        [super setValue:nil forKey:property.type];
    }
    
    GCParameterAssert(property.describedObject == nil);
}

- (void)_internalAddValue:(id)value forKey:(NSString *)key {
    GCTag *tag = [GCTag tagNamed:key];
    
    if ([value isKindOfClass:[GCProperty class]]) {
        [self _internalAddProperty:value];
    } else if ([value isKindOfClass:[GCValue class]]) {
        [self _internalAddProperty:[[tag.objectClass alloc] initWithValue:value]];
    } else if ([value isKindOfClass:[GCEntity class]]) {
        GCRelationship *relationship = [[tag.objectClass alloc] init];
        [self _internalAddProperty:relationship];
        relationship.target = value;
    } else {
        NSException *exception = [NSException exceptionWithName:@"GCInvalidKVCValueTypeException"
                                                         reason:[NSString stringWithFormat:@"Invalid value %@ for _internalSetValue:forKey:", value]
                                                       userInfo:nil];
        @throw exception;
    }
}

#pragma mark NSKeyValueCoding overrides

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (value && ([self.validPropertyTypes containsObject:key] || [GCTag tagNamed:key].isCustom)) {
        if ([self _allowsMultipleOccurrencesOfPropertyType:key]) {
            NSParameterAssert([value respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]);
            [super setValue:[NSMutableArray array] forKey:key];
            for (id item in value) {
                [self _internalAddValue:item forKey:key];
            }
        } else {
            [self _internalAddValue:value forKey:key];
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
        return [super valueForKey:key];
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
    [keyPaths addObject:@"allProperties"];
    [keyPaths addObject:@"orderedProperties"];
    
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

#pragma mark GCProperty collection accessors

- (NSUInteger)countOfProperties
{
    return [self.orderedProperties count];
}

- (NSEnumerator *)enumeratorOfProperties
{
    return [self.orderedProperties objectEnumerator];
}

- (GCProperty *)memberOfProperties:(GCProperty *)property
{
    for (GCProperty *p in [self enumeratorOfProperties]) {
        if ([p isEqual:property]) {
            return p;
        }
    }
    
    return nil;
}

- (void)addPropertiesObject:(GCProperty *)property
{
    [self _internalAddProperty:property];
}

- (void)removePropertiesObject:(GCProperty *)property
{
    [self _internalRemoveProperty:property];
}

/* //Optional. Implement if benchmarking indicates that performance is an issue.
 - (void)intersectProperties:(NSSet *)objects
 {
 
 }
 */

- (NSMutableSet *)allProperties
{
    return [self mutableSetValueForKey:@"properties"];
}

@end

@implementation GCObject (GCMoreConvenienceMethods)

- (void)addAttributeWithType:(NSString *)type value:(GCValue *)value
{
    [self _internalAddValue:value forKey:type];
}

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target
{
    [self _internalAddValue:target forKey:type];
}

@end