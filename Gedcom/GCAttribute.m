//
//  GCAttribute.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAttribute.h"

#import "GCNode.h"
#import "GCTag.h"

#import "GCEntity.h"

#import "GCValue.h"
#import "GCAge.h"
#import "GCDate.h"

@implementation GCAttribute{
    GCValue *_value;
}

#pragma mark Initialization

- (id)initForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCTag *tag = [[object gedTag] subTagWithCode:[node gedTag] type:@"attribute"];
    
    self = [super initWithType:[tag name]];
    
    if (self) {
        if ([node gedValue] != nil) {
            [self setValue:[[tag valueType] valueWithGedcomString:[node gedValue]]];
        }
        
        [self addPropertiesWithGedcomNodes:[node subNodes]];
        
        [[object mutableArrayValueForKey:@"properties"] addObject:self];
    }
    
    return self;
}

#pragma mark Convenience constructors

+ (id)attributeForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    return [[self alloc] initForObject:object withGedcomNode:node];
}

+ (id)attributeWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    [keyPaths addObject:@"value"];
    [keyPaths removeObject:key];
    
    return keyPaths;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[[self gedTag] code]
								 value:[_value gedcomString]
								  xref:nil
							  subNodes:[self subNodes]];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    [self setValueWithGedcomString:[gedcomNode gedValue]];
    
    [super setGedcomNode:gedcomNode];       
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if ([self value] != [(GCAttribute *)other value]) {
        return [[self value] compare:[(GCAttribute *)other value]];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _value = [aDecoder decodeObjectForKey:@"value"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_value forKey:@"value"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (value: %@)", [super description], [self value]];
}
//COV_NF_END

#pragma mark Objective-C properties

@synthesize value = _value;

- (NSString *)displayValue
{
    return [[self value] displayString];
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:[self displayValue]];
}

@end

@implementation GCAttribute (GCConvenienceMethods)

+ (id)attributeWithType:(NSString *)type value:(GCValue *)value
{
    GCAttribute *attribute = [self attributeWithType:type];
    
    [attribute setValue:value];
    
    return attribute;
}

+ (id)attributeWithType:(NSString *)type gedcomStringValue:(NSString *)value
{
    GCAttribute *attribute = [self attributeWithType:type];
    
    [attribute setValueWithGedcomString:value];
    
    return attribute;
}

- (void)setValueWithGedcomString:(NSString *)string
{
    [self setValue:[[[self gedTag] valueType] valueWithGedcomString:string]];
}

@end
