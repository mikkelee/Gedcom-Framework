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

#import "GCValue.h"
#import "GCAge.h"
#import "GCDate.h"

@implementation GCAttribute{
    GCValue *_value;
}

#pragma mark Convenience constructors

+ (id)attributeWithGedcomNode:(GCNode *)node
{
    GCAttribute *object = [[self alloc] initWithType:[[node gedTag] name]];
    
    if ([node gedValue] != nil) {
        switch ([[node gedTag] valueType]) {
            case GCStringValue:
                [object setStringValue:[node gedValue]];
                break;
                
            case GCNumberValue: {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [object setNumberValue:[formatter numberFromString:[node gedValue]]];
            }
                break;
                
            case GCAgeValue:
                [object setAgeValue:[GCAge ageFromGedcom:[node gedValue]]];
                break;
                
            case GCDateValue:
                [object setDateValue:[GCDate dateFromGedcom:[node gedValue]]];
                break;
                
            case GCBoolValue:
                [object setBoolValue:[[node gedValue] isEqualToString:@"Y"]];
                break;
                
            case GCRecordReferenceValue:
                //TODO
                break;
                
            default:
                break;
        }
    }
    
    for (id subNode in [node subNodes]) {
        [object addProperty:[GCProperty propertyWithGedcomNode:subNode]];
    }
    
    return object;
}

+ (id)attributeWithType:(NSString *)type
{
	return [[self alloc] initWithType:type];
}

+ (id)attributeWithType:(NSString *)type value:(GCValue *)value
{
    GCProperty *new = [[self alloc] initWithType:type];
    
    [new setValue:value];
    
    return new;
}

+ (id)attributeWithType:(NSString *)type stringValue:(NSString *)value
{
    return [self attributeWithType:type 
                          value:[[GCValue alloc] initWithType:GCStringValue value:value]]; 
}

+ (id)attributeWithType:(NSString *)type numberValue:(NSNumber *)value
{
    return [self attributeWithType:type 
                          value:[[GCValue alloc] initWithType:GCNumberValue value:value]]; 
}

+ (id)attributeWithType:(NSString *)type ageValue:(GCAge *)value
{
    return [self attributeWithType:type 
                          value:[[GCValue alloc] initWithType:GCAgeValue value:value]]; 
}

+ (id)attributeWithType:(NSString *)type dateValue:(GCDate *)value
{
    return [self attributeWithType:type 
                          value:[[GCValue alloc] initWithType:GCDateValue value:value]]; 
}

+ (id)attributeWithType:(NSString *)type boolValue:(BOOL)value
{
    return [self attributeWithType:type 
                          value:[[GCValue alloc] initWithType:GCBoolValue value:[NSNumber numberWithBool:value]]]; 
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

@end
