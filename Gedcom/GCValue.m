//
//  GCValue.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

#import "GCAge.h"
#import "GCDate.h"

@implementation GCValue {
    GCValueType _type;
    id _value;
}

- (id)initWithType:(GCValueType)type value:(id)value
{
    self = [super init];
    
    if (self) {
        _type = type;
        switch (_type) {
            case GCStringValue:
                NSParameterAssert([value isKindOfClass:[NSString class]]);
                break;
                
            case GCNumberValue:
                NSParameterAssert([value isKindOfClass:[NSNumber class]]);
                break;
                
            case GCAgeValue:
                NSParameterAssert([value isKindOfClass:[GCAge class]]);
                break;
                
            case GCDateValue:
                NSParameterAssert([value isKindOfClass:[GCDate class]]);
                break;
                
            case GCBoolValue:
                NSParameterAssert([value isKindOfClass:[NSNumber class]]);
                break;
                
            case GCGenderValue:
                NSParameterAssert([value isKindOfClass:[NSNumber class]]);
                break;
                
            default:
                break;
        }
        _value = value;
    }
    
    return self;
}

+ (GCValueType)valueTypeNamed:(NSString *)name
{
    if ([name isEqualToString:@"GCStringValue"]) {
        return GCStringValue;
    } else if ([name isEqualToString:@"GCNumberValue"]) {
        return GCNumberValue;
    } else if ([name isEqualToString:@"GCAgeValue"]) {
        return GCAgeValue;
    } else if ([name isEqualToString:@"GCDateValue"]) {
        return GCDateValue;
    } else if ([name isEqualToString:@"GCBoolValue"]) {
        return GCBoolValue;
    } else if ([name isEqualToString:@"GCGenderValue"]) {
        return GCGenderValue;
    } else {
        return GCUndefinedValue;
    }
}

- (NSString *)stringValue
{
    switch (_type) {
        case GCStringValue:
            return _value;
            break;
            
        case GCNumberValue:
            return [_value stringValue];
            break;
            
        case GCAgeValue:
            return [_value gedcomString];
            break;
            
        case GCDateValue:
            return [_value gedcomString];
            break;
            
        case GCBoolValue:
            return [_value boolValue] ? @"Y" : @"N";
            break;
            
        case GCGenderValue:
            if ([_value intValue] == GCMale) {
                return @"M";
            } else if ([_value intValue] == GCFemale) {
                return @"F";
            } else {
                return @"U";
            }
            break;
            
        default:
            break;
    }
    
    NSAssert(NO, @"Unable to coerce %@ to stringValue", _value);
    __builtin_unreachable();
}

- (NSNumber *)numberValue
{
    switch (_type) {
        case GCStringValue:
            return [NSNumber numberWithInt:[_value integerValue]];
            break;
            
        case GCNumberValue:
            return _value;
            break;
            
        case GCAgeValue:
            return [NSNumber numberWithInt:[_value years]];
            break;
            
        case GCDateValue:
            return [NSNumber numberWithInt:[_value year]];
            break;
            
        case GCBoolValue:
            break;
            
        case GCGenderValue:
            break;
            
        default:
            break;
    }
    
    NSAssert(NO, @"Unable to coerce %@ to numberValue", _value);
    __builtin_unreachable();
}

- (GCAge *)ageValue
{
    switch (_type) {
        case GCStringValue:
            return [GCAge ageWithGedcom:_value];
            break;
            
        case GCNumberValue:
            return [GCAge ageWithGedcom:[_value stringValue]];
            break;
            
        case GCAgeValue:
            return _value;
            break;
            
        case GCDateValue:
            break;
            
        case GCBoolValue:
            break;
            
        case GCGenderValue:
            break;
            
        default:
            break;
    }
    
    NSAssert(NO, @"Unable to coerce %@ to ageValue", _value);
    __builtin_unreachable();
}

- (GCDate *)dateValue
{
    switch (_type) {
        case GCStringValue:
            return [GCDate dateWithGedcom:_value];
            break;
            
        case GCNumberValue:
            return [GCDate dateWithGedcom:[_value stringValue]];
            break;
            
        case GCAgeValue:
            break;
            
        case GCDateValue:
            return _value;
            break;
            
        case GCBoolValue:
            break;
            
        case GCGenderValue:
            break;
            
        default:
            break;
    }
    
    NSAssert(NO, @"Unable to coerce %@ to dateValue", _value);
    __builtin_unreachable();
}

- (BOOL)boolValue
{
    switch (_type) {
        case GCStringValue:
            return [_value isEqualToString:@"Y"];
            break;
            
        case GCNumberValue:
            return [_value boolValue];
            break;
            
        case GCAgeValue:
            break;
            
        case GCDateValue:
            break;
            
        case GCBoolValue:
            return [_value boolValue];
            break;
            
        case GCGenderValue:
            break;
            
        default:
            break;
    }
    
    NSAssert(NO, @"Unable to coerce %@ to boolValue", _value);
    __builtin_unreachable();
}

- (GCGender)genderValue
{
    switch (_type) {
        case GCStringValue:
            if ([_value isEqualToString:@"M"]) {
                return GCMale;
            } else if ([_value isEqualToString:@"F"]) {
                return GCFemale;
            } else {
                return GCUnknownGender;
            }
            break;
            
        case GCNumberValue:
            break;
            
        case GCAgeValue:
            break;
            
        case GCDateValue:
            break;
            
        case GCBoolValue:
            break;
            
        case GCGenderValue:
			return [_value intValue];
            break;
            
        default:
            break;
    }
    
    NSAssert(NO, @"Unable to coerce %@ to genderValue", _value);
    __builtin_unreachable();
}

#pragma mark Comparison & equality

- (NSComparisonResult)compare:(id)other
{
    if (![other isKindOfClass:[self class]]) {
        return NSOrderedAscending;
    }
    
    switch (_type) {
        case GCStringValue:
            return [[self stringValue] compare:[other stringValue]];
            break;
            
        case GCNumberValue:
            return [[self numberValue] compare:[other numberValue]];
            break;
            
        case GCAgeValue:
            return [[self ageValue] compare:[other ageValue]];
            break;
            
        case GCDateValue:
            return [[self dateValue] compare:[other dateValue]];
            break;
            
        case GCBoolValue:
            return [[NSNumber numberWithBool:[self boolValue]] compare:[NSNumber numberWithBool:[other boolValue]]];
            break;
            
        case GCGenderValue:
            return [[NSNumber numberWithInt:[self genderValue]] compare:[NSNumber numberWithInt:[other genderValue]]];
            break;
            
        default:
            break;
    }
    
    return NSOrderedAscending;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if (![super isEqual:other]) {
        return NO;
    }
    
    return ([self compare:other] == NSOrderedSame);
}

- (NSUInteger)hash
{
    NSUInteger hash = 0;
    
    hash += [[NSNumber numberWithInt:_type] hash];
    hash += [_value hash];
    
    return hash;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [self initWithType:[aDecoder decodeIntegerForKey:@"type"] 
                        value:[aDecoder decodeObjectForKey:@"value"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeObject:_value forKey:@"value"];
}

@end

@implementation GCValue (GCConvenienceMethods)

+ (id)valueWithString:(NSString *)value
{
    return [[self alloc] initWithType:GCStringValue value:value];
}

+ (id)valueWithNumber:(NSNumber *)value
{
    return [[self alloc] initWithType:GCNumberValue value:value];
}

+ (id)valueWithAge:(GCAge *)value
{
    return [[self alloc] initWithType:GCAgeValue value:value];
}

+ (id)valueWithDate:(GCDate *)value
{
    return [[self alloc] initWithType:GCDateValue value:value];
}

+ (id)valueWithBool:(BOOL)value
{
    return [[self alloc] initWithType:GCBoolValue value:[NSNumber numberWithBool:value]];
}

+ (id)valueWithGender:(GCGender)value
{
    return [[self alloc] initWithType:GCGenderValue value:[NSNumber numberWithInt:value]];
}

@end