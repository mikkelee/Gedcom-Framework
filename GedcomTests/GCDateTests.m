//
//  GCDateTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCDateTests : SenTestCase
@end

@implementation GCDateTests

- (void)testSimpleDateNumeralMonth
{
	GCDate *result = [GCDate valueWithGedcomString:@"05 12 1831"];
	
	STAssertEqualObjects([result className], @"GCSimpleDate", nil);
	STAssertEqualObjects([result gedcomString], @"5 DEC 1831", nil);
}

- (void)testSimpleDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"FEB 1765"];
	
	STAssertEqualObjects([result className], @"GCSimpleDate", nil);
	STAssertEqualObjects([result gedcomString], @"FEB 1765", nil);
}

- (void)testHebrewDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"@#DHEBREW@ 2 TVT 5758"];
	
	STAssertEqualObjects([result className], @"GCSimpleDate", nil);
	STAssertEqualObjects([result gedcomString], @"@#DHEBREW@ 2 TVT 5758", nil);
}

- (void)testApproximateDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"ABT 12 JAN 1900"];
	
	STAssertEqualObjects([result className], @"GCApproximateDate", nil);
	STAssertEqualObjects([result gedcomString], @"ABT 12 JAN 1900", nil);
}

- (void)testInterpretedDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"INT 4 MAR 1799 (guesstimate)"];
	
	STAssertEqualObjects([result className], @"GCInterpretedDate", nil);
	STAssertEqualObjects([result gedcomString], @"INT 4 MAR 1799 (guesstimate)", nil);
}

- (void)testDatePeriod
{
	GCDate *result = [GCDate valueWithGedcomString:@"FROM JUN 1920 TO 12 AUG 1935"];
	
	STAssertEqualObjects([result className], @"GCDatePeriod", nil);
	STAssertEqualObjects([result gedcomString], @"FROM JUN 1920 TO 12 AUG 1935", nil);
    
    result = [GCDate valueWithGedcomString:@"FROM 2001"];
	
	STAssertEqualObjects([result className], @"GCDatePeriod", nil);
	STAssertEqualObjects([result gedcomString], @"FROM 2001", nil);
    
    result = [GCDate valueWithGedcomString:@"TO 1 APR 1920"];
	
	STAssertEqualObjects([result className], @"GCDatePeriod", nil);
	STAssertEqualObjects([result gedcomString], @"TO 1 APR 1920", nil);
}

- (void)testDateRange
{
	GCDate *result = [GCDate valueWithGedcomString:@"BET 1840 AND 1845"];
	
	STAssertEqualObjects([result className], @"GCDateRange", nil);
	STAssertEqualObjects([result gedcomString], @"BET 1840 AND 1845", nil);
    
    result = [GCDate valueWithGedcomString:@"BEF 1980"];
	
	STAssertEqualObjects([result className], @"GCDateRange", nil);
	STAssertEqualObjects([result gedcomString], @"BEF 1980", nil);
    
    result = [GCDate valueWithGedcomString:@"AFT 1700"];
	
	STAssertEqualObjects([result className], @"GCDateRange", nil);
	STAssertEqualObjects([result gedcomString], @"AFT 1700", nil);
}

- (void)testDatePhrase
{
	GCDate *result = [GCDate valueWithGedcomString:@"(Dato ukendt)"];
	
	STAssertEqualObjects([result className], @"GCDatePhrase", nil);
	STAssertEqualObjects([result gedcomString], @"(Dato ukendt)", nil);
}

@end
