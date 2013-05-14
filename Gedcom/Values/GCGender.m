//
//  GCGender.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"
#import "Gedcom_internal.h"

@implementation GCGender {
    NSString *_gedcomString;
    NSString *_displayString;
}

__strong static NSDictionary *_genderStore;

+ (void)initialize
{
    _genderStore = @{@"M": [[GCGender alloc] initWithGedcomString:@"M" displayString:@"Male"],
                     @"F": [[GCGender alloc] initWithGedcomString:@"F" displayString:@"Female"],
                     @"U": [[GCGender alloc] initWithGedcomString:@"U" displayString:@"Unknown"]};
}

- (instancetype)initWithGedcomString:(NSString *)gedcomString displayString:(NSString *)displayString
{
    self = [super init];
    
    if (self) {
        _gedcomString = gedcomString;
        _displayString = displayString;
    }
    
    return self;
}

+ (instancetype)valueWithGedcomString:(NSString *)string
{
    GCGender *value = _genderStore[string];
    
    if (value == nil) {
        value = _genderStore[@"U"];
    }
    
    return value;
}

+ (instancetype)maleGender
{
    return [self valueWithGedcomString:@"M"];
}

+ (instancetype)femaleGender
{
    return [self valueWithGedcomString:@"F"];
}

+ (instancetype)unknownGender
{
    return [self valueWithGedcomString:@"U"];
}

- (NSComparisonResult)compare:(GCGender *)other
{
    return [_gedcomString compare:other.gedcomString];
}

@synthesize gedcomString = _gedcomString;

- (NSString *)displayString
{
    return GCLocalizedString(_displayString, @"Values");
}

@end
