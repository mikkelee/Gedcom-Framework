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

#import "GCEntity_internal.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCValue.h"

@implementation GCEntity (GCGedcomLoadingAdditions)

- (id)initWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    if (tag.hasXref) {
        self = [context _entityForXref:node.xref create:YES withClass:tag.objectClass];
    } else if (tag.isCustom) {
        self = [self _initWithType:tag.name inContext:context];
    } else {
        self = [self initInContext:context];
    }
    
    if (self) {
        _isBuildingFromGedcom = YES;
        
        if (tag.hasValue)
            self.value = [GCString valueWithGedcomString:node.gedValue];
        
        [self addPropertiesWithGedcomNodes:node.subNodes];
        
        _isBuildingFromGedcom = NO;
    }
    
    return self;
}

@end

@implementation GCProperty (GCGedcomLoadingAdditions)

- (id)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (tag.isCustom) {
        self = [self _initWithType:tag.name];
    } else {
        self = [self init];
    }
    
    if (self) {
        if (tag.isCustom || object.gedTag.isCustom) {
            [object.mutableCustomProperties addObject:self];
        } else if ([object.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
            [[object mutableArrayValueForKey:tag.pluralName] addObject:self];
        } else {
            [object setValue:self forKey:tag.name];
        }
        
        NSParameterAssert(self.describedObject == object);
        
        [self addPropertiesWithGedcomNodes:node.subNodes];
    }
    
    return self;
}

@end

@implementation GCAttribute (GCGedcomLoadingAdditions)

- (id)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [super initWithGedcomNode:node onObject:object];
    
    if (self) {
        if (node.gedValue) {
            [self setValueWithGedcomString:node.gedValue];
        }
    }
    
    return self;
}

@end

@implementation GCRelationship (GCGedcomLoadingAdditions)

- (id)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
//TODO: cleanup
{
    GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:@"relationship"];
    
    id target = [object.context _entityForXref:node.gedValue create:YES withClass:tag.targetType];
    
    if ([object.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        if ([[[object valueForKey:tag.pluralName] valueForKey:@"target"] containsObject:target]) {
            return nil; // already exists
        }
    } else {
        if ([[object valueForKey:tag.name] valueForKey:@"target"] == target) {
            return nil; // already exists
        }
    }
    
    self = [super initWithGedcomNode:node onObject:object];
    
    if (self) {
        NSParameterAssert(self.describedObject == object);
        GCParameterAssert(object.context);
        
        self.target = target;
        
        NSParameterAssert(self.target);
    }
    
    return self;
}

@end