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
    GCTag *tag = [GCTag tagCoded:@"INDI"];
    GCTag *tag2 = [GCTag tagCoded:@"INDI"];
    
	STAssertNotNil(tag, nil);
	STAssertEquals(tag, tag2, nil);
	
    NSLog(@"allowedSubTags: %@", [tag validSubTags]);
    
    STAssertTrue([tag isValidSubTag:[GCTag tagCoded:@"NAME"]], nil);
    STAssertFalse([tag isValidSubTag:[GCTag tagCoded:@"HUSB"]], nil);
}

@end
