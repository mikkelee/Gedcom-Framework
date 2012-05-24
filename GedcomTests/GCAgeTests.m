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
	GCAge *age = [GCAge valueWithGedcomString:@"3y 1m 2d"];
	
	STAssertEqualObjects(NSStringFromClass([age class]), @"GCSimpleAge", nil);
	STAssertEqualObjects([age gedcomString], @"3y 1m 2d", nil);
	
    //will only pass if localization isn't changed from English:
    STAssertEqualObjects([age displayString], @"3 years, 1 month, 2 days", nil);
}

- (void)testAgeKeyword
{
	GCAge *age = [GCAge valueWithGedcomString:@"INFANT"];
	
	STAssertEqualObjects(NSStringFromClass([age class]), @"GCAgeKeyword", nil);
	STAssertEqualObjects([age gedcomString], @"INFANT", nil);
}

- (void)testQualifiedAge
{
	GCAge *age = [GCAge valueWithGedcomString:@"< 10d"];
	
	STAssertEqualObjects(NSStringFromClass([age class]), @"GCQualifiedAge", nil);
	STAssertEqualObjects([age gedcomString], @"< 10d", nil);
}

- (void)testAgeSort
{
	GCAge *age1 = [GCAge valueWithGedcomString:@"1y 20d"];
	GCAge *age2 = [GCAge valueWithGedcomString:@"4y 1m"];
	
	STAssertEquals((NSInteger)NSOrderedAscending, [age1 compare:age2], nil);
}

@end
