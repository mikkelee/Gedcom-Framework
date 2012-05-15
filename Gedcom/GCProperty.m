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

#import "GCAttribute.h"
#import "GCRelationship.h"

@interface GCProperty ()

@property (weak) GCObject *primitiveDescribedObject;

@end

@implementation GCProperty 

#pragma mark Convenience constructors

+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCTag *tag = [[object gedTag] subTagWithCode:[node gedTag] type:([[node gedValue] hasPrefix:@"@"] ? @"relationship" : @"attribute")];
    
	if ([tag objectClass] == [GCAttribute class]) {
		return [GCAttribute attributeForObject:object withGedcomNode:node];
	} else if ([tag objectClass] == [GCRelationship class]) {
		return [GCRelationship relationshipForObject:object withGedcomNode:node];
	} else {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidObjectClassException"
														 reason:[NSString stringWithFormat:@"Invalid <objectClass> '%@' on %@ for %@", [tag objectClass], node, object]
													   userInfo:nil];
		@throw exception;
	}
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

- (GCContext *)context
{
    return [_describedObject context];
}

@end
