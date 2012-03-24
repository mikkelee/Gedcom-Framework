//
//  GCTagTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "GCTag.h"

@interface GCTagTests : SenTestCase {
	
}

@end

@implementation GCTagTests

- (void)testTags
{
    GCTag *indi1 = [GCTag tagCoded:@"INDI"];
    GCTag *indi2 = [GCTag tagNamed:@"Individual"];
    
	STAssertNotNil(indi1, nil);
	STAssertEquals(indi1, indi2, nil);
	
    STAssertTrue([indi1 isValidSubTag:[GCTag tagCoded:@"NAME"]], nil);
    STAssertFalse([indi1 isValidSubTag:[GCTag tagCoded:@"HUSB"]], nil);
    
    STAssertEqualObjects([indi2 code], @"INDI", nil);
    STAssertEqualObjects([indi2 name], @"Individual", nil);
}

@end
