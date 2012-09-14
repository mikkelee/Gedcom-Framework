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

-(void)testSimpleDateNumeralMonth
{
	GCDate *result = [GCDate valueWithGedcomString:@"05 12 1831"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCSimpleDate", nil);
	STAssertEqualObjects([result gedcomString], @"5 DEC 1831", nil);
}

-(void)testSimpleDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"FEB 1765"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCSimpleDate", nil);
	STAssertEqualObjects([result gedcomString], @"FEB 1765", nil);
}

-(void)testApproximateDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"ABT 12 JAN 1900"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCApproximateDate", nil);
	STAssertEqualObjects([result gedcomString], @"ABT 12 JAN 1900", nil);
}

-(void)testInterpretedDate
{
	GCDate *result = [GCDate valueWithGedcomString:@"INT 4 MAR 1799 (guesstimate)"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCInterpretedDate", nil);
	STAssertEqualObjects([result gedcomString], @"INT 4 MAR 1799 (guesstimate)", nil);
}

-(void)testDatePeriod
{
	GCDate *result = [GCDate valueWithGedcomString:@"FROM JUN 1920 TO 12 AUG 1935"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCDatePeriod", nil);
	STAssertEqualObjects([result gedcomString], @"FROM JUN 1920 TO 12 AUG 1935", nil);
}

-(void)testDateRange
{
	GCDate *result = [GCDate valueWithGedcomString:@"BET 1840 AND 1845"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCDateRange", nil);
	STAssertEqualObjects([result gedcomString], @"BET 1840 AND 1845", nil);
}

-(void)testDatePhrase
{
	GCDate *result = [GCDate valueWithGedcomString:@"(Dato ukendt)"];
	
	STAssertEqualObjects(NSStringFromClass([result class]), @"GCDatePhrase", nil);
	STAssertEqualObjects([result gedcomString], @"(Dato ukendt)", nil);
}

@end
