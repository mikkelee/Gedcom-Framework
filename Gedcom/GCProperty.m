//
//  GCProperty.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

#import "GCNode.h"

@interface GCProperty ()

@property (weak) GCObject *primitiveDescribedObject;

@end

@implementation GCProperty

#pragma mark Initialization

- (id)initForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (!tag.isCustom) {
        self = [self init];
    } else {
        self = [super initWithType:tag.name];
    }
    
    if (self) {
        [object.allProperties addObject:self];
        
        [self addPropertiesWithGedcomNodes:node.subNodes];
    }
    
    return self;
}


#pragma mark Convenience constructors

+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    return [[self alloc] initForObject:object withGedcomNode:node];
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    if (![other isKindOfClass:[self class]]) {
        return NSOrderedAscending;
    }
    
    if (self.describedObject != [(GCProperty *)other describedObject]) {
        return [self.describedObject compare:[(GCProperty *)other describedObject]];
    }
    
    if (self.type != [(GCProperty *)other type]) {
        return [self.type compare:[(GCProperty *)other type]];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _primitiveDescribedObject = [aDecoder decodeObjectForKey:@"describedObject"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.describedObject forKey:@"describedObject"];
}

#pragma mark Objective-C properties

- (GCObject *)describedObject
{
    return self.primitiveDescribedObject;
}

- (void)setDescribedObject:(GCObject *)describedObject
{
    [self willChangeValueForKey:@"describedObject"];
    if (_primitiveDescribedObject) {
        if (_primitiveDescribedObject != describedObject) {
            [_primitiveDescribedObject.allProperties removeObject:self];
        }
    }
    self.primitiveDescribedObject = describedObject;
    [_primitiveDescribedObject.allProperties addObject:self];
    [self didChangeValueForKey:@"describedObject"];
}

- (GCObject *)rootObject
{
    return self.describedObject.rootObject;
}

- (GCContext *)context
{
    return self.describedObject.context;
}

@end
