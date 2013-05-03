//
//  GCTagAccessAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTagAccessAdditions.h"

#import "GCTag.h"

@implementation GCObject (GCGedcomPropertyAdditions)

__strong static NSMutableDictionary *_validPropertiesByType;

+ (void)load
{
    _validPropertiesByType = [NSMutableDictionary dictionary];
}

+ (NSOrderedSet *)validPropertyTypes
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

+ (GCTag *)gedTag
{
    GCTag *tag = [GCTag tagWithObjectClass:self];
    
    if (!tag && [[self className] hasPrefix:@"NSKVONotifying_"]) {
        // FIXME: KVO subclasses w NSKVONotifying_ prefix ruin tagwithObjectClass.
        // This hack fixes it, but is ugly and easy to break since it relies on undocumented implementation details
        tag = [GCTag tagWithObjectClass:[self superclass]];
    }
    
    NSParameterAssert(tag);
    
	return tag;
}

- (GCTag *)gedTag
{
    return [[self class] gedTag];
}

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

- (NSOrderedSet *)validPropertyTypes
{
    return [[self class] validPropertyTypes];
}

+ (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type
{
    return [self.gedTag allowedOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type
{
    return [[self class] allowedOccurrencesOfPropertyType:type];
}

+ (BOOL)allowsMultipleOccurrencesOfPropertyType:(NSString *)type
{
    return [self.gedTag allowsMultipleOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (BOOL)allowsMultipleOccurrencesOfPropertyType:(NSString *)type
{
    return [[self class] allowsMultipleOccurrencesOfPropertyType:type];
}

+ (NSArray *)propertyTypesInGroup:(NSString *)groupName
{
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    for (GCTag *tag in [self.gedTag subTagsInGroup:groupName]) {
        [propertyTypes addObject:tag.pluralName];
    }
    
    return [propertyTypes count] > 0 ? [propertyTypes copy] : nil;
}

- (NSArray *)propertyTypesInGroup:(NSString *)groupName
{
    return [[self class] propertyTypesInGroup:groupName];
}

+ (NSString *)gedcomCode
{
    return self.gedTag.code;
}

- (NSString *)gedcomCode
{
    return [[self class] gedcomCode];
}

+ (NSString *)type
{
    return self.gedTag.name;
}

+ (NSString *)localizedType
{
    return self.gedTag.localizedName;
}

+ (NSString *)pluralType
{
    return self.gedTag.pluralName;
}

- (NSString *)type
{
    return [[self class] type];
}

- (NSString *)localizedType
{
    return [[self class] localizedType];
}

- (NSString *)pluralType
{
    return [[self class] pluralType];
}

@end

@implementation GCEntity (GCTagAccessAdditions)

- (BOOL)takesValue
{
    return self.gedTag.takesValue;
}

@end

@implementation GCAttribute (GCTagAccessAdditions)

- (Class)valueType
{
    return self.gedTag.valueType;
}

- (NSArray *)allowedValues
{
    return self.gedTag.allowedValues;
}

- (BOOL)allowsNilValue
{
    return self.gedTag.allowsNilValue;
}

@end

@implementation GCRelationship (GCTagAccessAdditions)

- (Class)targetType
{
    return self.gedTag.targetType;
}

@end