//
//  GCDateAgeMathTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 27/04/12
//  Copyright 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCDateAgeMathTests : SenTestCase
@end


@implementation GCDateAgeMathTests

- (void)testAgeFromDateToDate
{
    GCDate *date1, *date2;
    GCAge *age;
    
    date1 = [GCDate valueWithGedcomString:@"1900"];
    date2 = [GCDate valueWithGedcomString:@"1910"];
    
    age = [GCAge ageFromDate:date1 toDate:date2];
    
	STAssertEqualObjects(@"[GCSimpleAge (10 years, 0 months, 0 days)]", [age description], nil);
    
    date2 = [GCDate valueWithGedcomString:@"MAY 1910"];
    
    age = [GCAge ageFromDate:date1 toDate:date2];
    
	STAssertEqualObjects(@"[GCSimpleAge (10 years, 4 months, 0 days)]", [age description], nil);
}

- (void)testDateByAddingAge
{
    GCDate *date = [GCDate valueWithGedcomString:@"12 OCT 2002"];
    GCAge *age = [GCAge valueWithGedcomString:@"12y 3m"]; 
    
    GCDate *date2 = [date dateByAddingAge:age];
    
	STAssertEqualObjects(@"[GCSimpleDate (gregorian) 2015 1 12]", [date2 description], nil);
}

@end
