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
    GCAttribute *attribute = [[self alloc] initWithType:[[node gedTag] name]];
    
    if ([node gedValue] != nil) {
        switch ([[node gedTag] valueType]) {
            case GCStringValue:
                [attribute setStringValue:[node gedValue]];
                break;
                
            case GCNumberValue: {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [attribute setNumberValue:[formatter numberFromString:[node gedValue]]];
            }
                break;
                
            case GCAgeValue:
                [attribute setAgeValue:[GCAge ageWithGedcom:[node gedValue]]];
                break;
                
            case GCDateValue:
                [attribute setDateValue:[GCDate dateWithGedcom:[node gedValue]]];
                break;
                
            case GCBoolValue:
                [attribute setBoolValue:[[node gedValue] isEqualToString:@"Y"]];
                break;
                
            case GCGenderValue:
				if ([[node gedValue] isEqualToString:@"M"]) {
					[attribute setGenderValue:GCMale];
				} else if ([[node gedValue] isEqualToString:@"F"]) {
					[attribute setGenderValue:GCFemale];
				} else {
					[attribute setGenderValue:GCUnknownGender];
				}
                break;
                
            default:
                NSAssert(NO, @"Shouldn't happen");
                break;
        }
    }
    
    for (id subNode in [node subNodes]) {
        [GCProperty propertyForObject:attribute withGedcomNode:subNode];
    }
    
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
    return [[GCNode alloc] initWithTag:[self gedTag] 
								 value:[self stringValue]
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

#pragma mark Objective-C properties

@synthesize value = _value;

- (void)setGenderValue:(GCGender)genderValue
{
    _value = [[GCValue alloc] initWithType:GCGenderValue value:[NSNumber numberWithInt:genderValue]];
}

- (GCGender)genderValue
{
    return [_value genderValue];
}

@end

@implementation GCAttribute (GCConvenienceMethods)

+ (id)attributeWithType:(NSString *)type value:(GCValue *)value
{
    GCAttribute *attribute = [self attributeWithType:type];
    
    [attribute setValue:value];
    
    return attribute;
}

+ (id)attributeWithType:(NSString *)type stringValue:(NSString *)value
{
    return [self attributeWithType:type 
                             value:[GCValue valueWithString:value]]; 
}

+ (id)attributeWithType:(NSString *)type numberValue:(NSNumber *)value
{
    return [self attributeWithType:type 
                             value:[GCValue valueWithNumber:value]]; 
}

+ (id)attributeWithType:(NSString *)type ageValue:(GCAge *)value
{
    return [self attributeWithType:type 
                             value:[GCValue valueWithAge:value]]; 
}

+ (id)attributeWithType:(NSString *)type dateValue:(GCDate *)value
{
    return [self attributeWithType:type 
                             value:[GCValue valueWithDate:value]]; 
}

+ (id)attributeWithType:(NSString *)type boolValue:(BOOL)value
{
    return [self attributeWithType:type 
                             value:[GCValue valueWithBool:value]]; 
}

+ (id)attributeWithType:(NSString *)type genderValue:(GCGender)value
{
    return [self attributeWithType:type 
                             value:[GCValue valueWithGender:value]]; 
}


- (void)setStringValue:(NSString *)stringValue
{
    _value = [[GCValue alloc] initWithType:GCStringValue value:stringValue];
}

- (NSString *)stringValue
{
    return [_value stringValue];
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    _value = [[GCValue alloc] initWithType:GCNumberValue value:numberValue];
}

- (NSNumber *)numberValue
{
    return [_value numberValue];
}

- (void)setAgeValue:(GCAge *)ageValue
{
    _value = [[GCValue alloc] initWithType:GCAgeValue value:ageValue];
}

- (GCAge *)ageValue
{
    return [_value ageValue];
}

- (void)setDateValue:(GCDate *)dateValue
{
    _value = [[GCValue alloc] initWithType:GCDateValue value:dateValue];
}

- (GCDate *)dateValue
{
    return [_value dateValue];
}

- (void)setBoolValue:(BOOL)boolValue
{
    _value = [[GCValue alloc] initWithType:GCBoolValue value:[NSNumber numberWithBool:boolValue]];
}

- (BOOL)boolValue
{
    return [_value boolValue];
}

@end
