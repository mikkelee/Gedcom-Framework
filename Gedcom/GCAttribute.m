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

#import "GCAge.h"
#import "GCDate.h"

@implementation GCAttribute{
    GCValue *_value;
}

#pragma mark Convenience constructors

+ (id)attributeForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCAttribute *attribute = [[self alloc] initWithType:[[node gedTag] name] inContext:[object context]];
    
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
                [attribute setAgeValue:[GCAge ageFromGedcom:[node gedValue]]];
                break;
                
            case GCDateValue:
                [attribute setDateValue:[GCDate dateFromGedcom:[node gedValue]]];
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
                break;
        }
    }
    
    for (id subNode in [node subNodes]) {
        [attribute addProperty:[GCProperty propertyForObject:object withGedcomNode:subNode]];
    }
    
    return attribute;
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type
{
    GCAttribute *attribute = [[self alloc] initWithType:type inContext:[object context]];
    
	[attribute setDescribedObject:object];
    
    return attribute;
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type value:(GCValue *)value
{
    GCAttribute *attribute = [self attributeForObject:object withType:type];
    
    [attribute setValue:value];
    
    return attribute;
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type stringValue:(NSString *)value
{
    return [self attributeForObject:object
						   withType:type 
							  value:[[GCValue alloc] initWithType:GCStringValue value:value]]; 
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type numberValue:(NSNumber *)value
{
    return [self attributeForObject:object
						   withType:type 
							  value:[[GCValue alloc] initWithType:GCNumberValue value:value]]; 
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type ageValue:(GCAge *)value
{
    return [self attributeForObject:object
						   withType:type 
							  value:[[GCValue alloc] initWithType:GCAgeValue value:value]]; 
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type dateValue:(GCDate *)value
{
    return [self attributeForObject:object
						   withType:type 
							  value:[[GCValue alloc] initWithType:GCDateValue value:value]]; 
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type boolValue:(BOOL)value
{
    return [self attributeForObject:object
						   withType:type 
							  value:[[GCValue alloc] initWithType:GCBoolValue value:[NSNumber numberWithBool:value]]]; 
}

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type genderValue:(GCGender)value
{
    return [self attributeForObject:object
						   withType:type 
							  value:[[GCValue alloc] initWithType:GCGenderValue value:[NSNumber numberWithInt:value]]]; 
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag] 
								 value:[self stringValue]
								  xref:nil
							  subNodes:[self subNodes]];
}

#pragma mark Properties

@synthesize value = _value;

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

- (void)setGenderValue:(GCGender)genderValue
{
    _value = [[GCValue alloc] initWithType:GCGenderValue value:[NSNumber numberWithInt:genderValue]];
}

- (GCGender)genderValue
{
    return [_value genderValue];
}

@end
