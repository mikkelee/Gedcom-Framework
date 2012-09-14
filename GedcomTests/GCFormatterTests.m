//
//  GCFormatterTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12
//  Copyright 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCFormatterTests : SenTestCase
@end


@implementation GCFormatterTests

- (void)testBoolFormatter
{
    GCBoolFormatter *formatter = [[GCBoolFormatter alloc] init];
    
    GCBool *obj = [GCBool yes];
    
    NSString *displayString = [formatter stringForObjectValue:obj];
    
    STAssertEqualObjects(displayString, @"Yes", nil);
    
    NSString *gedcomString = [formatter editingStringForObjectValue:obj];
    
    STAssertEqualObjects(gedcomString, @"Y", nil);
    
    NSString *error = nil;
    
    [formatter getObjectValue:&obj forString:@"" errorDescription:&error];
    
    STAssertEqualObjects(obj, [GCBool undecided], nil);
}

@end
