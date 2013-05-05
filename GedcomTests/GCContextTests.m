//
//  GCContextTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <Gedcom/Gedcom.h>

@interface GCContextTests : SenTestCase

@end

@implementation GCContextTests

- (void)testDefaultHeader {
    GCContext *ctx = [GCContext context];
    
    GCHeaderEntity *head = [GCHeaderEntity defaultHeaderInContext:ctx];
    
    //TODO insert version number from plist.
    NSString *expected =
    @"0 HEAD\n"
    @"1 SOUR Gedcom.framework\n"
    @"2 VERS 0.9.4\n"
    @"2 NAME Gedcom.framework\n"
    @"2 CORP Mikkel Eide Eriksen\n"
    @"3 ADDR http://github.com/mikkelee/Gedcom-Framework\n"
    @"1 SUBM @SUBM1@\n"
    @"1 GEDC\n"
    @"2 VERS 5.5\n"
    @"2 FORM LINEAGE-LINKED\n"
    @"1 CHAR UNICODE";
    
    STAssertEqualObjects(head.gedcomString, expected, nil);
}

@end
