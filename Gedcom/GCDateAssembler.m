//
//  GCDateAssembler.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 20/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <ParseKit/ParseKit.h>
#import "GCDateAssembler.h"
#import "GCDate.h"

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

@implementation GCDateAssembler

- (GCDateAssembler *)init
{	
	if (![super init])
		return nil;
	
	monthNames = [@"JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" componentsSeparatedByString:@" "];
	[self initialize];
	
	return self;
}

- (void)initialize
{
	[self setDate:nil];
	currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchYear:(PKAssembly *)a
{
	[currentDateComponents setYear:[[[a pop] stringValue] intValue]];
}


- (void)didMatchMonthNumeral:(PKAssembly *)a
{
	[currentDateComponents setMonth:[[[a pop] stringValue] intValue]];
}


- (void)didMatchMonthWord:(PKAssembly *)a
{
	[currentDateComponents setMonth:[monthNames indexOfObject:[[a pop] stringValue]]+1];
}


- (void)didMatchDay:(PKAssembly *)a
{
	[currentDateComponents setDay:[[[a pop] stringValue] intValue]];
}


- (void)didMatchYearGreg:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
}


- (void)didMatchDateGreg:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	[a push:[GCDate simpleDate:currentDateComponents]];
	
	currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchDateJuln:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	[a push:[GCDate simpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:nil]]];
	
	currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchMonthHebr:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
}


- (void)didMatchDateHebr:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	[a push:[GCDate simpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar]]];
	
	currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchMonthFren:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
}


- (void)didMatchDateFren:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	[a push:[GCDate simpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:nil]]];
	
	currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchDateSimple:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
}


- (void)didMatchDatePhraseContents:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
}


- (void)didMatchDatePeriod:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
	id aDate = [a pop];
	id keyword = [a pop];
	if ([[keyword stringValue] isEqualToString:@"TO"]) {
		if ([a isStackEmpty]) {
			[a push:[GCDate datePeriodFrom:nil to:aDate]];
		} else {
			id anotherDate = [a pop];
			id keyword = [a pop];
			if ([[keyword stringValue] isEqualToString:@"FROM"]) {
				[a push:[GCDate datePeriodFrom:anotherDate to:aDate]];
			}
		}
	} else if ([[keyword stringValue] isEqualToString:@"FROM"]) {
		[a push:[GCDate datePeriodFrom:aDate to:nil]];
	}
}


- (void)didMatchDateRange:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id aDate = [a pop];
	id keyword = [a pop];
	if ([a isStackEmpty]) {
		if ([[keyword stringValue] isEqualToString:@"BEF"]) {
			[a push:[GCDate dateRangeFrom:nil to:aDate]];
		} else if ([[keyword stringValue] isEqualToString:@"AFT"]) {
			[a push:[GCDate dateRangeFrom:aDate to:nil]];
		}
	} else {
		if ([[keyword stringValue] isEqualToString:@"AND"]) {
			id anotherDate = [a pop];
			id keyword = [a pop];
			if ([[keyword stringValue] isEqualToString:@"BET"]) {
				[a push:[GCDate dateRangeFrom:anotherDate to:aDate]];
			}
		}
	}
}


- (void)didMatchDateApproximated:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id simpleDate = [a pop];
	id type = [a pop];
	[a push:[GCDate approximateDate:simpleDate withType:[type stringValue]]];
}


- (void)didMatchDateInterpreted:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id phrase = [a pop];
	id simpleDate = [a pop];
	id keyword = [a pop];
	if ([[keyword stringValue] isEqualToString:@"INT"]) {
		[a push:[GCDate interpretedDate:simpleDate withPhrase:phrase]];		
	} else {
		NSLog(@"This shouldn't happen (keyword wasn't INT): %@", keyword);
	}
}


- (void)didMatchDatePhrase:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id endParen = [a pop];
	
	if ([[endParen stringValue] isEqualToString:@")"]) {
		id contents;
		
		NSString *phrase = [[a pop] stringValue];
		
		while ( (contents = [[a pop] stringValue]) ) {
			if ([contents isEqualToString:@"("]) {
				break;
			}
			phrase = [NSString stringWithFormat:@"%@ %@", contents, phrase];
		}
		
		[a push:[GCDate datePhrase:phrase]];
	} else {
		NSLog(@"This shouldn't happen (endParen wasn't ')'): %@", endParen);
	}
}


- (void)didMatchDate:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	
	if ([[a stack] count] == 1) {
		DebugLog(@"Stack was empty, setting date");
		[self setDate:[a pop]];
	} else {
		DebugLog(@"ERROR: Objects remaining on stack!");
		DebugLog(@"stack: %@", [a stack]);
	}
}

@synthesize date;

@end
