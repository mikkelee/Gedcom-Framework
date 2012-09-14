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
                              @"1 CHAN\n"
                              @"2 DATE %@\n"
                              @"3 TIME %@",
                              date,
                              time
                              ];
    
    GCNode *changeNode = [[GCNode arrayOfNodesFromString:gedcomString] lastObject];
    
    //NSLog(@"changeNode: %@", changeNode);
    
    NSDate *changeDate = dateFromNode(changeNode);
    
    NSDate *expectedDate = [NSDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"%@ %@", date, time]];
    
    STAssertEqualObjects(changeDate, expectedDate, nil);
    
    //and the reverse:
    
    GCNode *newNode = nodeFromDate(changeDate);
    
    //NSLog(@"newNode: %@", newNode);
    
    STAssertEqualObjects([changeNode gedcomString], [newNode gedcomString], nil);
}

- (void)testDates
{
    [self testDate:@"2 MAY 2009" time:@"20:07:12"];
    [self testDate:@"12 MAY 1999" time:@"01:02:03"];
}

@end
