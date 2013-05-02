//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

#import "GCObject+GCConvenienceAdditions.h"
#import "GCGedcomLoadingAdditions.h"
#import "GCGedcomAccessAdditions.h"
#import "GCTagAccessAdditions.h"

@implementation GCObject {
    NSMutableArray *_customProperties;
}

//static const NSString *GCColorPreferenceKey = @"GCColorPreferenceKey";

#pragma mark Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _customProperties = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark Comparison & equality

- (NSComparisonResult)compare:(id)other
{
    //subclasses override to get actual result.
    NSParameterAssert([self class] == [other class]);
    return NSOrderedSame;
}

- (BOOL)isEqualTo:(GCObject *)other
{
    return [self.gedcomString isEqualToString:other.gedcomString];
}

#pragma mark NSCopying conformance

- (id)copyWithZone:(NSZone *)zone
{
    // deep copy
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

#pragma mark NSCoding conformance

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        for (NSString *propertyType in self.validPropertyTypes) {
            id obj = [aDecoder decodeObjectForKey:propertyType];
            if (obj) {
                [super setValue:obj forKey:propertyType];
            }
        }
        @synchronized(_customProperties) {
            _customProperties = [aDecoder decodeObjectForKey:@"customProperties"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.type forKey:@"type"];
    for (NSString *propertyType in self.validPropertyTypes) {
        [aCoder encodeObject:[super valueForKey:propertyType] forKey:propertyType];
    }
    @synchronized(_customProperties) {
        [aCoder encodeObject:_customProperties forKey:@"customProperties"];
    }
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSLog(@"You must override this method in your subclass!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)_propertyDescriptionWithIndent:(NSUInteger)level
{
    NSMutableString *out = [NSMutableString string];
    
    for (GCObject *property in self.properties) {
        [out appendString:[property descriptionWithIndent:level+1]];
    }
    
    return out;
}
//COV_NF_END

#pragma mark Objective-C properties

@dynamic rootObject;
@dynamic context;

- (NSUndoManager *)undoManager
{
    return self.rootObject.undoManager;
}

- (NSArray *)properties
{
    NSMutableArray *properties = [NSMutableArray array];
    
    for (NSString *propertyType in self.validPropertyTypes) {
        if ([self allowsMultipleOccurrencesOfPropertyType:propertyType]) {
            [properties addObjectsFromArray:[super valueForKey:propertyType]];
        } else {
            if ([self valueForKey:propertyType]) {
                [properties addObject:[super valueForKey:propertyType]];
            }
        }
    }
    
    [properties addObjectsFromArray:_customProperties];
    
	return [properties copy];
}

- (NSMutableArray *)mutableProperties
{
    return [self mutableArrayValueForKey:@"properties"];
}

- (NSUInteger)countOfProperties
{
    return [self.properties count];
}

- (id)objectInPropertiesAtIndex:(NSUInteger)index {
    return [self.properties objectAtIndex:index];
}

- (void)insertObject:(GCObject *)prop inPropertiesAtIndex:(NSUInteger)index {
    if ([self allowsMultipleOccurrencesOfPropertyType:prop.type]) {
        [[self mutableArrayValueForKey:prop.pluralType] addObject:prop];
    } else {
        [self setValue:prop forKey:prop.type];
    }
}

- (void)removeObjectFromPropertiesAtIndex:(NSUInteger)index {
    GCObject *prop = self.properties[index];
    
    if ([self allowsMultipleOccurrencesOfPropertyType:prop.type]) {
        [[self mutableArrayValueForKey:prop.pluralType] removeObject:prop];
    } else {
        [self setValue:nil forKey:prop.type];
    }
}

- (NSMutableArray *)mutableCustomProperties {
    return [self mutableArrayValueForKey:@"customProperties"];
}

- (NSUInteger)countOfCustomProperties
{
    return [_customProperties count];
}

- (id)objectInCustomPropertiesAtIndex:(NSUInteger)index {
    return [_customProperties objectAtIndex:index];
}

- (void)insertObject:(GCObject *)obj inCustomPropertiesAtIndex:(NSUInteger)index {
    [obj setValue:self forKey:@"describedObject"];
    [_customProperties insertObject:obj atIndex:index];
}

- (void)removeObjectFromCustomPropertiesAtIndex:(NSUInteger)index {
    [_customProperties[index] setValue:nil forKey:@"describedObject"];
    [_customProperties removeObjectAtIndex:index];
}

@end