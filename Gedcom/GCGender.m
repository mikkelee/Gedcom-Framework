//
//  GCGender.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGender.h"

@implementation GCGender {
    NSString *_gedcomString;
    NSString *_displayString;
}

__strong static NSDictionary *genderStore;

+ (void)initialize
{
    genderStore = @{@"M": [[GCGender alloc] initWithGedcomString:@"M" displayString:@"Male"],
                    @"F": [[GCGender alloc] initWithGedcomString:@"F" displayString:@"Female"],
                    @"U": [[GCGender alloc] initWithGedcomString:@"U" displayString:@"Unknown"]};
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
    return [genderStore valueForKey:string];
}

+ (id)maleGender
{
    return [self valueWithGedcomString:@"M"];
}

+ (id)femaleGender
{
    return [self valueWithGedcomString:@"F"];
}

+ (id)unknownGender
{
    return [self valueWithGedcomString:@"U"];
}

- (NSComparisonResult)compare:(id)other
{
    return [[self gedcomString] compare:[other gedcomString]];
}

@synthesize gedcomString = _gedcomString;

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    return [frameworkBundle localizedStringForKey:_displayString value:_displayString table:@"Values"];
}

@end
