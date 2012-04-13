//
//  GCInvalidDate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCInvalidDate.h"

#import "GCSimpleDate.h"

@implementation GCInvalidDate

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCInvalidDate '%@']", [self string]];
}

-(NSString *)gedcomString
{
	return [self string];
}

- (GCSimpleDate *)refDate
{
	return nil;
}

- (NSCalendar *)calendar
{
	return nil;
}

@synthesize string;

@end
