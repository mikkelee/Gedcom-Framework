//
//  GCDateApproximate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCApproximateDate.h"
#import "GCSimpleDate.h"

@implementation GCApproximateDate

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCApproximateDate '%@' %@]", [self dateType], [self simpleDate]];
}

-(NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", [self dateType], [[self simpleDate] gedcomString]];
}

@synthesize dateType;

@end
