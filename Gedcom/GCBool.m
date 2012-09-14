//
//  GCBool.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCBool.h"

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

- (id)initWithGedcomString:(NSString *)gedcomString displayString:(NSString *)displayString
{
    self = [super init];
    
    if (self) {
        _gedcomString = gedcomString;
        _displayString = displayString;
    }
    
    return self;
}

+ (id)valueWithGedcomString:(NSString *)string
{
    GCBool *value = _boolStore[string];
    
    if (value == nil) {
        value = _boolStore[@""];
    }
    
    return value;
}

+ (id)yes
{
    return [self valueWithGedcomString:@"Y"];
}

+ (id)undecided
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
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    return [frameworkBundle localizedStringForKey:_displayString value:_displayString table:@"Values"];
}

- (BOOL)boolValue
{
    return [_gedcomString isEqualToString:@"Y"];
}

@end
