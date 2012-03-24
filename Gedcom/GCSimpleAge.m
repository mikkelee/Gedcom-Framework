//
//  GCSimpleAge.m
//  GCCoreData copy
//
//  Created by Mikkel Eide Eriksen on 08/06/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCSimpleAge.h"
#import "GCAge.h"

@implementation GCSimpleAge

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setAgeComponents:[coder decodeObjectForKey:@"components"]];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self ageComponents] forKey:@"components"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCSimpleAge (%d years, %d months, %d days)]", [[self ageComponents] year], [[self ageComponents] month], [[self ageComponents] day]];
}

- (NSString *)gedcomString
{
	NSString *months = @"";
	if ([[self ageComponents] month] >= 1) {
		months = [NSString stringWithFormat:@" %@", [[self ageComponents] month]];
	}
	
	NSString *days = @"";
	if ([[self ageComponents] day] >= 1) {
		days = [NSString stringWithFormat:@" %dd", [[self ageComponents] day]];
	}
	
	return [NSString stringWithFormat:@"%dy%@%@", [[self ageComponents] year], months, days];
}

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleAge class]]) {
		if ([[self ageComponents] year] != [[other ageComponents] year]) {
			return [[NSNumber numberWithInt:[[self ageComponents] year]] compare:[NSNumber numberWithInt:[[other ageComponents] year]]];
		} else if ([[self ageComponents] month] != [[other ageComponents] month]) {
			return [[NSNumber numberWithInt:[[self ageComponents] month]] compare:[NSNumber numberWithInt:[[other ageComponents] month]]];
		} else {
			return [[NSNumber numberWithInt:[[self ageComponents] day]] compare:[NSNumber numberWithInt:[[other ageComponents] day]]];
		}
	} else {
		return [self compare:[other refAge]];
	}
}

- (GCSimpleAge *)copyWithZone:(NSZone *)zone
{
	GCSimpleAge *age = [[GCSimpleAge alloc] init];
	
	[age setAgeComponents:[self ageComponents]];
	
	return age;
}

- (GCSimpleAge *)refAge
{
	return self;
}

@synthesize ageComponents;

@end
