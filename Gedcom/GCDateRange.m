//
//  GCDateRange.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDateRange.h"
#import "GCSimpleDate.h"

@implementation GCDateRange

- (NSString *)description
{
	if ([self dateA] == nil) {
		return [NSString stringWithFormat:@"[GCDateRange BEF %@]", [self dateB]];
	} else if ([self dateB] == nil) {
		return [NSString stringWithFormat:@"[GCDateRange AFT %@]", [self dateA]];
	} else {
		return [NSString stringWithFormat:@"[GCDateRange BET %@ AND %@]", [self dateA], [self dateB]];
	}
}

- (NSString *)gedcomString
{
	if ([self dateA] == nil) {
		return [NSString stringWithFormat:@"BEF %@", [[self dateB] gedcomString]];
	} else if ([self dateB] == nil) {
		return [NSString stringWithFormat:@"AFT %@", [[self dateA] gedcomString]];
	} else {
		return [NSString stringWithFormat:@"BET %@ AND %@", [[self dateA] gedcomString], [[self dateB] gedcomString]];
	}
}

@end
