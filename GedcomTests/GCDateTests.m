//
//  GCDateTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 16/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCDateTests : SenTestCase
@end

@implementation GCDateTests

-(void)testSimpleDateNumeralMonth
{
	GCDate *result = [GCDate dateWithGedcom:@"05 12 1831"];
	
	STAssertEqualObjects(@"[GCSimpleDate (gregorian) 1831 12 5]", [result description], nil);
}

-(void)testSimpleDate
{
	GCDate *result = [GCDate dateWithGedcom:@"FEB 1765"];
	
	STAssertEqualObjects(@"[GCSimpleDate (gregorian) 1765 2 -1]", [result description], nil);
}

-(void)testApproximateDate
{
	GCDate *result = [GCDate dateWithGedcom:@"ABT 12 JAN 1900"];
	
	STAssertEqualObjects(@"[GCApproximateDate 'ABT' [GCSimpleDate (gregorian) 1900 1 12]]", [result description], nil);
}

-(void)testInterpretedDate
{
	GCDate *result = [GCDate dateWithGedcom:@"INT 4 MAR 1799 (guesstimate)"];
	
	STAssertEqualObjects(@"[GCInterpretedDate [GCSimpleDate (gregorian) 1799 3 4] [GCDatePhrase 'guesstimate']]", [result description], nil);
}

-(void)testDatePeriod
{
	GCDate *result = [GCDate dateWithGedcom:@"FROM JUN 1920 TO 12 AUG 1935"];
	
	STAssertEqualObjects(@"[GCDatePeriod FROM [GCSimpleDate (gregorian) 1920 6 -1] TO [GCSimpleDate (gregorian) 1935 8 12]]", [result description], nil);
}

-(void)testDateRange
{
	GCDate *result = [GCDate dateWithGedcom:@"BET 1840 AND 1845"];
	
	STAssertEqualObjects(@"[GCDateRange BET [GCSimpleDate (gregorian) 1840 -1 -1] AND [GCSimpleDate (gregorian) 1845 -1 -1]]", [result description], nil);
}

-(void)testDatePhrase
{
	GCDate *result = [GCDate dateWithGedcom:@"(Dato ukendt)"];
	
	STAssertEqualObjects(@"[GCDatePhrase 'Dato ukendt']", [result description], nil);
}

@end
