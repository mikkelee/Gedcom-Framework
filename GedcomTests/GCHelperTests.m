//
//  GCHelperTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

#import "Helpers.h"

@interface GCHelperTests : SenTestCase
@end


@implementation GCHelperTests

- (void)testDate:(NSString *)date time:(NSString *)time
{
    NSString *gedcomString = [NSString stringWithFormat:
                              @"1 DATE %@\n"
                              @"2 TIME %@",
                              date,
                              time
                              ];
    
    GCNode *changeNode = [[GCNode arrayOfNodesFromString:gedcomString] lastObject];
    
    //NSLog(@"changeNode: %@", changeNode);
    
    NSDate *changeDate = dateFromNode(changeNode);
    
    NSDate *expectedDate = [NSDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"%@ %@ +0000", date, time]];
    
    STAssertEqualObjects(changeDate, expectedDate, nil);
    
    //and the reverse:
    
    GCNode *newNode = nodeFromDate(changeDate);
    
    //NSLog(@"newNode: %@", newNode);
    
    STAssertEqualObjects([changeNode gedcomString], [newNode gedcomString], nil);
    
    STAssertEqualObjects([changeNode gedcomString], [nodeFromDate(expectedDate) gedcomString], nil);
}

- (void)testDates
{
    // Test both summer & winter time, and single + two digit days/hours
    
    [self testDate:@"2 MAY 2009" time:@"01:07:12"];
    [self testDate:@"11 NOV 2004" time:@"23:30:14"];
    
}

@end
