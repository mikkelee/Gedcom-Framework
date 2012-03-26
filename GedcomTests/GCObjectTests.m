//
//  GCObjectTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "GCRecord.h"
#import "GCNode.h"
#import "GCTag.h"
#import "GCDate.h"
#import "GCAge.h"

@interface GCObjectTests : SenTestCase {
	
}

@end

@implementation GCObjectTests

- (void)testSimpleObjects
{
    GCRecord *indi = [GCRecord objectWithType:@"Individual"];
    
    [indi addRecordWithType:@"Name" stringValue:@"Jens /Hansen/"];
    [indi addRecordWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
    GCRecord *birt = [GCRecord objectWithType:@"Birth" boolValue:YES];
    
    [birt addRecordWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    [indi addRecord:birt];
    
    STAssertEqualObjects([[indi gedcomNode] gedcomString], 
                         @"0 @I1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT Y\n"
                         @"2 DATE 1 JAN 1901", nil);
    
    
    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagCoded:@"INDI"] 
                                         value:nil
                                          xref:nil
                                      subNodes:[NSArray arrayWithObjects:
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"NAME"] 
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"NAME"] 
                                                              value:@"Jens /Hansen/"],
                                                [[GCNode alloc] initWithTag:[GCTag tagCoded:@"BIRT"] 
                                                                      value:@"Y"
                                                                       xref:nil
                                                                   subNodes:[NSArray arrayWithObjects:
                                                                             [GCNode nodeWithTag:[GCTag tagCoded:@"DATE"]
                                                                                                           value:@"1 JAN 1901"],
                                                                              nil]
                                                                             ],
                                                 nil]];
    
    GCRecord *object = [GCRecord objectWithGedcomNode:node];
    
    STAssertEqualObjects([[indi gedcomNode] gedcomString], 
                         [[object gedcomNode] gedcomString], nil);
}

- (void)testObjectValues
{
    GCRecord *date = [GCRecord objectWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    STAssertEqualObjects([date stringValue], @"1 JAN 1901", nil);
}

@end
