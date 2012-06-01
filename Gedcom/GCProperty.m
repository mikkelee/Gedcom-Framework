//
//  GCProperty.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

#import "GCNode.h"
#import "GCTag.h"

@interface GCProperty ()

@property (weak) GCObject *primitiveDescribedObject;

@end

@implementation GCProperty

#pragma mark Initialization

- (id)initForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCTag *tag = [[object gedTag] subTagWithCode:[node gedTag] type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (!tag) {
        // for debugging; TODO remove when tags.json is complete.
        NSLog(@"rootObject: %@", [object rootObject]);
        NSLog(@"object: %@", object);
        NSLog(@"node: %@", node);
    }
    
    self = [super initWithType:[tag name]];
    
    if (self) {
        [self addPropertiesWithGedcomNodes:[node subNodes]];
        
        [[object mutableArrayValueForKey:@"properties"] addObject:self];
    }
    
    return self;
}


#pragma mark Convenience constructors

+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    Class propertySubClass = NSClassFromString([NSString stringWithFormat:@"GC%@", [([node valueIsXref] ? @"relationship" : @"attribute") capitalizedString]]);
    
    return [[propertySubClass alloc] initForObject:object withGedcomNode:node];
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    if (![other isKindOfClass:[self class]]) {
        return NSOrderedAscending;
    }
    
    if ([self describedObject] != [(GCProperty *)other describedObject]) {
        return [[self describedObject] compare:[(GCProperty *)other describedObject]];
    }
    
    if ([self type] != [(GCProperty *)other type]) {
        return [[self type] compare:[(GCProperty *)other type]];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setValue:[aDecoder decodeObjectForKey:@"describedObject"] forKey:@"primitiveDescribedObject"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self describedObject] forKey:@"describedObject"];
}

#pragma mark Objective-C properties

@synthesize primitiveDescribedObject = _describedObject;

- (GCObject *)describedObject
{
    return [self primitiveDescribedObject];
}

- (void)setDescribedObject:(GCObject *)describedObject
{
    [self willChangeValueForKey:@"describedObject"];
    if (_describedObject) {
        if (_describedObject == self) {
            return;
        }
        [[_describedObject valueForKey:@"properties"] removeObject:self];
    }
    [self setPrimitiveDescribedObject:describedObject];
    [[_describedObject mutableArrayValueForKey:@"properties"] addObject:self];
    [self didChangeValueForKey:@"describedObject"];
}

- (GCObject *)rootObject
{
    return [[self describedObject] rootObject];
}

- (GCContext *)context
{
    return [_describedObject context];
}

@end
