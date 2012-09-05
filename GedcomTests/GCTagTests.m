//
//  GCTagTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCTagTests : SenTestCase
@end

@implementation GCTagTests

- (void)testTags
{
    GCTag *indi1 = [GCTag rootTagWithCode:@"INDI"];
    GCTag *indi2 = [GCTag tagNamed:@"individual"];
    
	STAssertNotNil(indi1, nil);
	STAssertEquals(indi1, indi2, nil);
	
    STAssertTrue([indi1 isValidSubTag:[indi1 subTagWithCode:@"NAME" type:@"attribute"]], nil);
    STAssertFalse([indi1 isValidSubTag:[indi1 subTagWithCode:@"HUSB" type:@"relationship"]], nil);
    
    STAssertEqualObjects([indi2 code], @"INDI", nil);
    STAssertEqualObjects([indi1 name], @"individual", nil);
    
    STAssertEquals([[indi1 subTagWithCode:@"NAME" type:@"attribute"] valueType], [GCNamestring class], nil);
    STAssertEquals([[indi1 subTagWithCode:@"BIRT" type:@"attribute"] valueType], [GCBool class], nil);
}

- (void)testInvalidTagName
{
    STAssertThrowsSpecificNamed([GCTag tagNamed:@"INVALID TAG NAME"], NSException, @"GCInvalidTagNameException", nil);
}

@end
