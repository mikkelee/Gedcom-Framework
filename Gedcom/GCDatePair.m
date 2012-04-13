//
//  GCDatePair.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDatePair.h"
#import "GCSimpleDate.h"
#import "GCAttributedDate.h"
#import "GCDatePhrase.h"

@implementation GCDatePair

//TODO enforce [dateA calendar] isEqual [dateB calendar]

- (GCSimpleDate *)refDate
{
	if ([self dateA] == nil) {
		return [self dateB];
	} else if ([self dateB] == nil) {
		return [self dateA];
	} else {
		GCSimpleDate *m = [[GCSimpleDate alloc] init];
		
		[m setCalendar:[[self dateA] calendar]];
		[m setDateComponents:[[[self dateA] calendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[[self dateA] date] dateByAddingTimeInterval:[[[self dateB] date] timeIntervalSinceDate:[[self dateA] date]]/2]]];
		 
		return m;
	}
}

- (NSCalendar *)calendar
{
	if ([self dateA]) {
		return [[self dateA] calendar];
	} else {
		return [[self dateB] calendar];
	}
}

@synthesize dateA;
@synthesize dateB;

@end
