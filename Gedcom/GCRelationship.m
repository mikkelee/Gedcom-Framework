//
//  GCRelationnship.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCRelationship.h"

#import "GCEntity.h"
#import "GCNode.h"
#import "GCTag.h"
#import "GCContext.h"

@implementation GCRelationship {
	GCEntity *_target;
}

#pragma mark Initialization

- (id)initForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    self = [super initForObject:object withGedcomNode:node];
    
    if (self) {
        [[object context] registerCallbackForXref:[node gedValue] usingBlock:^(NSString *xref) {
            GCEntity *target = [[object context] entityForXref:xref];
            //NSLog(@"Set %@ => %@ on %@", xref, target, relationship);
            [self setTarget:target];
        }];
    }
    
    return self;
}

#pragma mark Convenience constructors

+ (id)relationshipForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    return [[self alloc] initForObject:object withGedcomNode:node];
}

+ (id)relationshipWithType:(NSString *)type
{
	return [[self alloc] initWithType:type];
}

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    [keyPaths addObject:@"target"];
    [keyPaths removeObject:key];
    
    return keyPaths;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[[self gedTag] code]
								 value:[[self context] xrefForEntity:_target]
								  xref:nil
							  subNodes:[self subNodes]];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    [self setTarget:[[self context] entityForXref:[gedcomNode gedValue]]];
    
    [super setGedcomNode:gedcomNode];
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if ([self target] != [(GCRelationship *)other target]) {
        return [[self target] compare:[(GCRelationship *)other target]];
    }
    
    return NSOrderedSame;
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (target: %@)", [super description], [[self context] xrefForEntity:[self target]]];
}
//COV_NF_END

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _target = [aDecoder decodeObjectForKey:@"target"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_target forKey:@"target"];
}

#pragma mark Objective-C properties

- (GCEntity *)target
{
    return _target;
}

- (void)setTarget:(GCEntity *)target
{
    NSParameterAssert([self describedObject]);
    NSParameterAssert([[[self gedTag] targetType] isEqualToString:[target type]]);
    
    if ([[self gedTag] reverseRelationshipTag]) {
        //remove previous reverse relationship before changing target.
        for (GCRelationship *relationship in [_target valueForKey:@"properties"]) {
            if (![relationship isKindOfClass:[GCRelationship class]]) {
                continue;
            }
            if ([[relationship target] isEqual:[self describedObject]]) {
                [[_target mutableArrayValueForKey:@"properties"] removeObject:relationship];
            }
        }
        if (target != nil) {
            //set up new reverse relationship
            BOOL relationshipExists = NO;
            for (GCRelationship *relationship in [target valueForKey:@"properties"]) {
                if (![relationship isKindOfClass:[GCRelationship class]]) {
                    continue;
                }
                if ([[relationship target] isEqual:[self describedObject]]) {
                    //NSLog(@"relationship: %@", relationship);
                    relationshipExists = YES;
                }
            }
            if (!relationshipExists) {
                [target addRelationshipWithType:[[[self gedTag] reverseRelationshipTag] name] 
                                         target:(GCEntity *)[self describedObject]];
            }
        }
    }
    
    _target = target;
}

- (NSString *)displayValue
{
    return [[self context] xrefForEntity:_target];
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:[self displayValue] 
                                           attributes:[NSDictionary dictionaryWithObject:[[self context] xrefForEntity:_target]
                                                                                  forKey:NSLinkAttributeName]];
}

@end

@implementation GCRelationship (GCConvenienceMethods)

+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target
{
    GCRelationship *relationship = [[self alloc] initWithType:type];
    
    [relationship setTarget:target];
	
    return relationship;
}

@end