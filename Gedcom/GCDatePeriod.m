//
//  GCDateRange.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDatePeriod.h"
#import "GCSimpleDate.h"

@implementation GCDatePeriod

- (NSString *)description
{
	if ([self dateA] == nil) {
		return [NSString stringWithFormat:@"[GCDateRange TO %@]", [self dateB]];
	} else if ([self dateB] == nil) {
		return [NSString stringWithFormat:@"[GCDateRange FROM %@]", [self dateA]];
	} else {
		return [NSString stringWithFormat:@"[GCDatePeriod FROM %@ TO %@]", [self dateA], [self dateB]];
	}
}

- (NSString *)gedcomString
{
	if ([self dateA] == nil) {
		return [NSString stringWithFormat:@"TO %@", [[self dateB] gedcomString]];
	} else if ([self dateB] == nil) {
		return [NSString stringWithFormat:@"FROM %@", [[self dateA] gedcomString]];
	} else {
		return [NSString stringWithFormat:@"FROM %@ TO %@", [self dateA], [self dateB]];
	}
}

- (GCDatePeriod *)copyWithZone:(NSZone *)zone
{
	GCDatePeriod *date = [[GCDatePeriod alloc] init];
	
	[date setDateA:[self dateA]];
	[date setDateB:[self dateB]];
	
	return date;
}

@end