//
//  GCFormatterTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 27/04/12
//  Copyright 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

#import "GCChangedDateFormatter.h"

@interface GCFormatterTests : SenTestCase
@end


@implementation GCFormatterTests

- (void)testChangedDateFormatter
{
    NSString *gedcomString = 
    @"1 CHAN\n"
    @"2 DATE 2 May 2009\n"
    @"3 TIME 20:07:12"
    ;
    
    GCNode *changeNode = [[GCNode arrayOfNodesFromString:gedcomString] lastObject];
    
    //NSLog(@"changeNode: %@", changeNode);
    
    NSDate *changeDate = [[GCChangedDateFormatter sharedFormatter] dateWithNode:changeNode];
    
    STAssertEqualObjects(changeDate, [NSDate dateWithNaturalLanguageString:@"2 May 2009 20:07:12"], nil);
    
    //and the reverse:
    
    GCNode *newNode = [[GCChangedDateFormatter sharedFormatter] nodeWithDate:changeDate];

    //NSLog(@"newNode: %@", newNode);
        
    STAssertEqualObjects([changeNode gedcomString], [newNode gedcomString], nil);
}

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
    
    STAssertEqualObjects(obj, [GCBool no], nil);
}

@end
