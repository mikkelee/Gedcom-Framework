//
//  GCDatePhrase.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDatePhrase.h"

#import "GCSimpleDate.h"

@implementation GCDatePhrase

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCDatePhrase '%@']", [self phrase]];
}

-(NSString *)gedcomString
{
	return [NSString stringWithFormat:@"(%@)", [self phrase]];
}

- (NSCalendar *)calendar
{
	return nil;
}

- (GCSimpleDate *)refDate
{
	return nil;
}

@synthesize phrase;

@end
