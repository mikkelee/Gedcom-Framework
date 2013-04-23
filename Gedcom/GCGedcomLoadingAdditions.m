//
//  GCGedcomLoadingAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGedcomLoadingAdditions.h"

#import "GCObject+GCConvenienceAdditions.h"

#import "GCNode.h"
#import "GCContext_internal.h"

#import "GCEntity.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCValue.h"

@implementation GCObject (GCGedcomLoadingAdditions)

- (void)_addPropertyWithGedcomNode:(GCNode *)node
{
    GCTag *tag = [self.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (tag.isCustom && ![self.context _shouldHandleCustomTag:tag forNode:node onObject:self]) {
        return;
    }
    
    switch (tag.type) {
        case GCTagTypeRelationship:
        {
            [self.context _defer:^{
                (void)[tag.objectClass newWithGedcomNode:node onObject:self];
            }];
        }
            break;
            
        case GCTagTypeAttribute:
            (void)[tag.objectClass newWithGedcomNode:node onObject:self];
            break;
            
        default:
            NSAssert(NO, @"WTF");
            break;
    }
}

- (void)_addPropertiesWithGedcomNodes:(NSArray *)nodes
{
    for (id node in nodes) {
        [self _addPropertyWithGedcomNode:node];
    }
}

@end

@implementation GCEntity (GCGedcomLoadingAdditions)

+ (instancetype)newWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    GCEntity *entity = [[tag.objectClass alloc] initInContext:context];
    
    NSParameterAssert(entity);
    
    if (entity) {
        entity->_isBuildingFromGedcom = YES;
        
        if (tag.hasValue)
            entity.value = [GCString valueWithGedcomString:node.gedValue];
        
        [entity _addPropertiesWithGedcomNodes:node.subNodes];
        
        entity->_isBuildingFromGedcom = NO;
    }
    
    return entity;
}

@end

@implementation GCRecord (GCGedcomLoadingAdditions)

+ (instancetype)newWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    GCRecord *record;
    
    if (tag.isCustom) {
        record = [[tag.objectClass alloc] initInContext:context];
    } else {
        record = [context _recordForXref:node.xref create:YES withClass:tag.objectClass];
    }
    
    NSParameterAssert(record);
    
    if (record) {
        record->_isBuildingFromGedcom = YES;
        
        if (tag.hasValue)
            record.value = [GCString valueWithGedcomString:node.gedValue];
        
        [record _addPropertiesWithGedcomNodes:node.subNodes];
        
        record->_isBuildingFromGedcom = NO;
    }
    
    return record;
}

@end

@implementation GCProperty (GCGedcomLoadingAdditions)

- (instancetype)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [self init];
    
    if (self) {
        _isBuildingFromGedcom = YES;
        
        GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
        
        if (tag.isCustom || object.gedTag.isCustom) {
            [object.mutableCustomProperties addObject:self];
        } else if ([object.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
            [[object mutableArrayValueForKey:tag.pluralName] addObject:self];
        } else {
            [object setValue:self forKey:tag.name];
        }
        
        NSParameterAssert(self.describedObject == object);
        
        [self _addPropertiesWithGedcomNodes:node.subNodes];
        
        _isBuildingFromGedcom = NO;
    }
    
    return self;
}

+ (instancetype)newWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    NSAssert(NO, @"You must use a subclass to instantiate properties");
    return nil;
}

@end

@implementation GCAttribute (GCGedcomLoadingAdditions)

- (instancetype)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [super initWithGedcomNode:node onObject:object];
    
    if (self) {
        _isBuildingFromGedcom = YES;
        
        if (node.gedValue) {
            [self setValueWithGedcomString:node.gedValue];
        }
        
        _isBuildingFromGedcom = NO;
    }
    
    return self;
}

+ (instancetype)newWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    return [[self alloc] initWithGedcomNode:node onObject:object];
}

@end

@implementation GCRelationship (GCGedcomLoadingAdditions)

- (instancetype)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [super initWithGedcomNode:node onObject:object];
    
    if (self) {
        _isBuildingFromGedcom = YES;
        
        NSParameterAssert(self.describedObject == object);
        GCParameterAssert(object.context);
        
        GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:@"relationship"];
        
        id target = [self.context _recordForXref:node.gedValue create:YES withClass:tag.targetType];
        
        NSParameterAssert(self.describedObject == object);
        
        self.target = target;
        
        NSParameterAssert(self.target);
        
        _isBuildingFromGedcom = NO;
    }
    
    return self;
}

+ (instancetype)newWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:@"relationship"];
    
    id target = [object.context _recordForXref:node.gedValue create:YES withClass:tag.targetType];
    
    if ([object.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        if ([[[object valueForKey:tag.pluralName] valueForKey:@"target"] containsObject:target]) {
            return nil; // already exists
        }
    } else {
        if ([[object valueForKey:tag.name] valueForKey:@"target"] == target) {
            return nil; // already exists
        }
    }
    
    return [[self alloc] initWithGedcomNode:node onObject:object];
}

@end