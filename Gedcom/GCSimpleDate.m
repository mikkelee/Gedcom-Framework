//
//  GCDateSimple.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCSimpleDate.h"
#import "GCDatePair.h"
#import "GCAttributedDate.h"
#import "GCDatePhrase.h"

@implementation GCSimpleDate

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setDateComponents:[coder decodeObjectForKey:@"components"]];
        [self setCalendar:[coder decodeObjectForKey:@"calendar"]];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self dateComponents] forKey:@"components"];
	[coder encodeObject:[self calendar] forKey:@"calendar"];
}

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleDate class]]) {
		if (![[self calendar] isEqual:[other calendar]]) {
			NSLog(@"WARNING: It is not safe at this moment to compare two GCDateSimples with different calendars.");
		}
		if ([[self dateComponents] year] != [[other dateComponents] year]) {
			return [[NSNumber numberWithInt:[[self dateComponents] year]] compare:[NSNumber numberWithInt:[[other dateComponents] year]]];
		} else if ([[self dateComponents] month] != [[other dateComponents] month]) {
			return [[NSNumber numberWithInt:[[self dateComponents] month]] compare:[NSNumber numberWithInt:[[other dateComponents] month]]];
		} else {
			return [[NSNumber numberWithInt:[[self dateComponents] day]] compare:[NSNumber numberWithInt:[[other dateComponents] day]]];
		}
	} else {
		return [self compare:[other refDate]];
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCSimpleDate (%@) %d %d %d]", [[self calendar] calendarIdentifier], [[self dateComponents] year], [[self dateComponents] month], [[self dateComponents] day]];
}

- (NSString *)gedcomString
{
	NSArray *monthNames = [@"JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" componentsSeparatedByString:@" "];
	
	NSString *month = @"";
	if ([[self dateComponents] month] >= 1 && [[self dateComponents] month] <= 12) {
		month = [NSString stringWithFormat:@"%@ ", [monthNames objectAtIndex:[[self dateComponents] month]-1]];
	}
	
	NSString *day = @"";
	if ([[self dateComponents] day] >= 1 && [[self dateComponents] day] <= 31) {
		day = [NSString stringWithFormat:@"%d ", [[self dateComponents] day]];
	}
	
	return [NSString stringWithFormat:@"%@%@%04d", day, month, [[self dateComponents] year]];
}

- (GCSimpleDate *)copyWithZone:(NSZone *)zone
{
	GCSimpleDate *date = [[GCSimpleDate alloc] init];
	
	[date setDateComponents:[self dateComponents]];
	[date setCalendar:[self calendar]];
	
	return date;
}

- (NSDate *)date
{
	return [[self calendar] dateFromComponents:[self dateComponents]];
}

- (GCSimpleDate *)refDate
{
	return self;
}

@synthesize dateComponents;
@synthesize calendar;

@end
