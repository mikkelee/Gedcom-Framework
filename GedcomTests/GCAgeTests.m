//
//  GCAgeTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 21/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCAgeTests : SenTestCase
@end


@implementation GCAgeTests

- (void)testSimpleAge
{
	GCAge *age = [GCAge ageWithGedcom:@"3y 2d"];
	
	STAssertEqualObjects(@"[GCSimpleAge (3 years, 0 months, 2 days)]", [age description], nil);
}

- (void)testAgeKeyword
{
	GCAge *age = [GCAge ageWithGedcom:@"INFANT"];
	
	STAssertEqualObjects(@"[GCAgeKeyword 'INFANT']", [age description], nil);
}

- (void)testQualifiedAge
{
	GCAge *age = [GCAge ageWithGedcom:@"< 10d"];
	
	STAssertEqualObjects(@"[GCQualifiedAge < [GCSimpleAge (0 years, 0 months, 10 days)]]", [age description], nil);
}

- (void)testAgeSort
{
	GCAge *age1 = [GCAge ageWithGedcom:@"1y 20d"];
	GCAge *age2 = [GCAge ageWithGedcom:@"4y 1m"];
	
	STAssertEquals((NSInteger)NSOrderedAscending, [age1 compare:age2], nil);
}

- (void)testAgeMath
{
    GCDate *date1, *date2;
    GCAge *age;
    
    date1 = [GCDate dateWithGedcom:@"1900"];
    date2 = [GCDate dateWithGedcom:@"1910"];
    
    age = [GCAge ageFromDate:date1 toDate:date2];
    
	STAssertEqualObjects(@"[GCSimpleAge (10 years, 0 months, 0 days)]", [age description], nil);
    
    date2 = [GCDate dateWithGedcom:@"MAY 1910"];
    
    age = [GCAge ageFromDate:date1 toDate:date2];
    
	STAssertEqualObjects(@"[GCSimpleAge (10 years, 4 months, 0 days)]", [age description], nil);
}

@end
