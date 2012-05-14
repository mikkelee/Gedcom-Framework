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

#pragma mark Convenience constructors

+ (id)attributeForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCTag *tag = [[object gedTag] subTagWithCode:[node gedTag] type:([[node gedValue] hasPrefix:@"@"] ? @"relationship" : @"attribute")];
    
    GCAttribute *attribute = [[self alloc] initWithType:[tag name]];
    
    if ([node gedValue] != nil) {
        [attribute setValue:[[tag valueType] valueWithGedcomString:[node gedValue]]];
    }
    
    [attribute addPropertiesWithGedcomNodes:[node subNodes]];
    
    [object addProperty:attribute];
    
    return attribute;
}

+ (id)attributeWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[[self gedTag] code]
								 value:[_value gedcomString]
								  xref:nil
							  subNodes:[self subNodes]];
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
	self = [super initWithType:[aDecoder decodeObjectForKey:@"type"]];
    
    if (self) {
        [self setValue:[aDecoder decodeObjectForKey:@"describedObject"] forKey:@"primitiveDescribedObject"];
        _value = [aDecoder decodeObjectForKey:@"value"];
        [self decodeProperties:aDecoder];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self type] forKey:@"type"];
    [aCoder encodeObject:[self describedObject] forKey:@"describedObject"];
    [aCoder encodeObject:_value forKey:@"value"];
    [self encodeProperties:aCoder];
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

@end

@implementation GCAttribute (GCConvenienceMethods)

+ (id)attributeWithType:(NSString *)type value:(GCValue *)value
{
    GCAttribute *attribute = [self attributeWithType:type];
    
    [attribute setValue:value];
    
    return attribute;
}

@end
