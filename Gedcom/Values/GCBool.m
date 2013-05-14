//
//  GCBool.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"
#import "Gedcom_internal.h"

@implementation GCBool {
    NSString *_gedcomString;
    NSString *_displayString;
}

__strong static NSDictionary *_boolStore;

+ (void)initialize
{
    _boolStore = @{@"Y": [[GCBool alloc] initWithGedcomString:@"Y" displayString:@"Yes"],
                    @"": [[GCBool alloc] initWithGedcomString:nil displayString:@"Undecided"]};
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
    GCBool *value = _boolStore[string];
    
    if (value == nil) {
        value = _boolStore[@""];
    }
    
    return value;
}

+ (instancetype)yes
{
    return [self valueWithGedcomString:@"Y"];
}

+ (instancetype)undecided
{
    return [self valueWithGedcomString:@""];
}

- (NSComparisonResult)compare:(id)other
{
    if ([self boolValue]) {
        if ([other boolValue]) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    } else {
        if ([other boolValue]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
}

@synthesize gedcomString = _gedcomString;

- (NSString *)displayString
{
    return GCLocalizedString(_displayString, @"Values");
}

- (BOOL)boolValue
{
    return [_gedcomString isEqualToString:@"Y"];
}

@end
