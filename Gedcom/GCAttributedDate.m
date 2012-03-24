//
//  GCAttributedDate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAttributedDate.h"
#import "GCSimpleDate.h"

@implementation GCAttributedDate

- (NSCalendar *)calendar
{
	return [[self simpleDate] calendar];
}

- (GCSimpleDate *)refDate
{
	return [self simpleDate];
}

@synthesize simpleDate;

@end
