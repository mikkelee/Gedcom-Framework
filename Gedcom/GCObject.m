//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

#import "GCTag.h"

#import "GCObject+GCConvenienceAdditions.h"
#import "GCGedcomLoadingAdditions.h"
#import "GCGedcomAccessAdditions.h"

__strong static NSMutableDictionary *_validPropertiesByType;

@implementation GCObject {
    NSMutableArray *_customProperties;
}

//static const NSString *GCColorPreferenceKey = @"GCColorPreferenceKey";

#pragma mark Initialization

+ (void)initialize
{
    _validPropertiesByType = [NSMutableDictionary dictionary];
}

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
    GCTag *tag = [GCTag tagNamed:prop.type];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] addObject:prop];
    } else {
        [self setValue:prop forKey:tag.name];
    }
}

- (void)removeObjectFromPropertiesAtIndex:(NSUInteger)index {
    GCObject *prop = self.properties[index];
    
    GCTag *tag = [GCTag tagNamed:prop.type];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] removeObject:prop];
    } else {
        [self setValue:nil forKey:tag.name];
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

@implementation GCObject (GCGedcomPropertyAdditions)

+ (Class)objectClassWithType:(NSString *)type
{
    return [GCTag tagNamed:type].objectClass;
}

+ (NSArray *)rootClasses
{
    NSMutableArray *rootTypes = [NSMutableArray array];
    
    for (GCTag *tag in [GCTag rootTags]) {
        [rootTypes addObject:tag.objectClass];
    }
    
    return [rootTypes copy];
}

#pragma mark GCProperty access

- (NSOrderedSet *)validPropertyTypes
{
    @synchronized(_validPropertiesByType) {
        NSOrderedSet *_validProperties = _validPropertiesByType[self.type];
        
        if (!_validProperties) {
            NSMutableOrderedSet *valid = [NSMutableOrderedSet orderedSetWithCapacity:[self.gedTag.validSubTags count]];
            
            for (GCTag *subTag in self.gedTag.validSubTags) {
                if ([self.gedTag allowedOccurrencesOfSubTag:subTag].max > 1) {
                    [valid addObject:subTag.pluralName];
                } else {
                    [valid addObject:subTag.name];
                }
            }
            
            _validProperties = [valid copy];
            
            _validPropertiesByType[self.type] = _validProperties;
        }
        
        return _validProperties;
    }
}

- (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type
{
    return [self.gedTag allowedOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (BOOL)allowsMultipleOccurrencesOfPropertyType:(NSString *)type
{
    return [self.gedTag allowsMultipleOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (NSArray *)propertyTypesInGroup:(NSString *)groupName
{
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    for (GCTag *tag in [self.gedTag subTagsInGroup:groupName]) {
        [propertyTypes addObject:tag.pluralName];
    }
    
    return [propertyTypes count] > 0 ? [propertyTypes copy] : nil;
}

+ (GCTag *)gedTag
{
	return [GCTag tagWithObjectClass:[self class]];
}

- (GCTag *)gedTag
{
    return [[self class] gedTag];
}

- (NSString *)type
{
    return self.gedTag.name;
}

- (NSString *)localizedType
{
    return self.gedTag.localizedName;
}

+ (NSString *)pluralType
{
    return self.gedTag.pluralName;
}

@end