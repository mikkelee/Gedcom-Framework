//
//  GCGedcomLoadingAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGedcomLoadingAdditions_internal.h"

#import "GCObject+GCConvenienceAdditions.h"

#import "GCNode.h"
#import "GCContext_internal.h"

#import "GCTag.h"
#import "GCTagAccessAdditions.h"

#import "GCEntity.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCValue.h"

#import "GCObjectProxy.h"

@implementation GCObject (GCGedcomLoadingAdditions)

- (void)_addPropertyWithGedcomNode:(GCNode *)node
{
    GCTag *tag = [self.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (tag.isCustom && ![self.context _shouldHandleCustomTag:tag forNode:node onObject:self]) {
        return;
    }
    
    (void)[tag.objectClass newWithGedcomNode:node onObject:self];
}

- (void)_addPropertiesWithGedcomNodes:(NSArray *)nodes
{
    for (id node in nodes) {
        [self _addPropertyWithGedcomNode:node];
    }
}

- (void)_waitUntilDoneBuildingFromGedcom
{
    if (self->_isBuildingFromGedcom) {
        dispatch_semaphore_wait(self->_buildingFromGedcomSemaphore, DISPATCH_TIME_FOREVER);
    }
}

@end

@implementation GCEntity (GCGedcomLoadingAdditions)

- (instancetype)initWithGedcomNode:(GCNode *)node useXref:(BOOL)useXref inContext:(GCContext *)context
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    if (!useXref || tag.isCustom) {
        self = [self initInContext:context];
    } else {
        self = [context _recordForXref:node.xref create:YES withClass:tag.objectClass];
    }
    
    NSParameterAssert(self);
    
    if (self) {
        GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
        
        self->_isBuildingFromGedcom = YES;
        self->_buildingFromGedcomSemaphore = dispatch_semaphore_create(0);
        
        if (tag.takesValue)
            self.value = [GCString valueWithGedcomString:node.gedValue];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self _addPropertiesWithGedcomNodes:node.subNodes];
            
            dispatch_semaphore_signal(self->_buildingFromGedcomSemaphore);
            self->_isBuildingFromGedcom = NO;
        });
    }
    
    return self;
}

+ (instancetype)newWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    id proxy = [[GCObjectProxy alloc] initWitBlock:^GCObject *{
        return [[self alloc] initWithGedcomNode:node useXref:NO inContext:context];
    }];
    
    return proxy;
}

@end

@implementation GCRecord (GCGedcomLoadingAdditions)

+ (instancetype)newWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    id proxy = [[GCObjectProxy alloc] initWitBlock:^GCObject *{
        return [[self alloc] initWithGedcomNode:node useXref:YES inContext:context];
    }];
    
    return proxy;
}

@end

@implementation GCProperty (GCGedcomLoadingAdditions)

- (instancetype)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [self init];
    
    if (self) {
        self->_isBuildingFromGedcom = YES;
        self->_buildingFromGedcomSemaphore = dispatch_semaphore_create(0);
        
        GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
        
        if (tag.isCustom || object.gedTag.isCustom) {
            [object.mutableCustomProperties addObject:self];
        } else if ([object.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
            [[object mutableArrayValueForKey:tag.pluralName] addObject:self];
        } else {
            [object setValue:self forKey:tag.name];
        }
        
        NSParameterAssert(self.describedObject == object);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self _addPropertiesWithGedcomNodes:node.subNodes];
            
            dispatch_semaphore_signal(self->_buildingFromGedcomSemaphore);
            self->_isBuildingFromGedcom = NO;
        });
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
        if (node.gedValue) {
            [self setValueWithGedcomString:node.gedValue];
        }
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
        NSParameterAssert(self.describedObject == object);
        GCParameterAssert(object.context);
        
        GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:@"relationship"];
        
        id target = [self.context _recordForXref:node.gedValue create:YES withClass:tag.targetType];
        
        NSParameterAssert(self.describedObject == object);
        
        self.target = target;
        
        NSParameterAssert(self.target);
    }
    
    return self;
}

+ (instancetype)newWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:@"relationship"];
    
    if (tag.hasReverse && !tag.isMain) {
        //NSLog(@"WARNING: dropping non-main reverse: %@", node);
        return nil;
    }
    
    return [[self alloc] initWithGedcomNode:node onObject:object];
}

@end