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
        _value = value;
    }
    
    return self;
}

- (NSComparisonResult)compare:(id)other
{
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

        default:
            break;
    }
}

- (NSString *)stringValue
{
    if ([_value isKindOfClass:[NSString class]]) {
        return _value;
    } else if ([_value isKindOfClass:[NSNumber class]]) {
        return [_value stringValue];
    } else if ([_value isKindOfClass:[GCAge class]]) {
        return [_value gedcomString];
    } else if ([_value isKindOfClass:[GCDate class]]) {
        return [_value gedcomString];
    } else {
        return nil; //TODO
    }
}

- (NSNumber *)numberValue
{
    if ([_value isKindOfClass:[NSString class]]) {
        return nil; //TODO
    } else if ([_value isKindOfClass:[NSNumber class]]) {
        return _value;
    } else if ([_value isKindOfClass:[GCAge class]]) {
        return [NSNumber numberWithInt:[_value years]];
    } else if ([_value isKindOfClass:[GCDate class]]) {
        return [NSNumber numberWithInt:[_value year]];
    } else {
        return nil; //TODO
    }
}

- (GCAge *)ageValue
{
    if ([_value isKindOfClass:[NSString class]]) {
        return [GCAge ageFromGedcom:_value];
    } else if ([_value isKindOfClass:[NSNumber class]]) {
        return [GCAge ageFromGedcom:[_value stringValue]];
    } else if ([_value isKindOfClass:[GCAge class]]) {
        return _value;
    } else if ([_value isKindOfClass:[GCDate class]]) {
        return nil; //TODO
    } else {
        return nil; //TODO
    }
}

- (GCDate *)dateValue
{
    if ([_value isKindOfClass:[NSString class]]) {
        return [GCDate dateFromGedcom:_value];
    } else if ([_value isKindOfClass:[NSNumber class]]) {
        return [GCDate dateFromGedcom:[_value stringValue]];
    } else if ([_value isKindOfClass:[GCAge class]]) {
        return nil; //TODO
    } else if ([_value isKindOfClass:[GCDate class]]) {
        return _value;
    } else {
        return nil; //TODO
    }
}

@end
