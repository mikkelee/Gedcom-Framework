//
//  GCObjectTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "GCEntity.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"
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
    GCEntity *indi = [GCEntity entityWithType:@"Individual"];
	
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
	GCAttribute *birt = [GCAttribute attributeWithType:@"Birth"];
    
	[birt addAttributeWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    [indi addAttribute:birt];
    
    [indi addAttributeWithType:@"Death" boolValue:YES];
    
    STAssertEqualObjects([[indi gedcomNode] gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y"
                         , nil);
    
    
    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagCoded:@"INDI"] 
                                         value:nil
                                          xref:@"@INDI2@"
                                      subNodes:[NSArray arrayWithObjects:
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"NAME"] 
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"NAME"] 
                                                              value:@"Jens /Hansen/"],
                                                [[GCNode alloc] initWithTag:[GCTag tagCoded:@"BIRT"] 
                                                                      value:nil
                                                                       xref:nil
                                                                   subNodes:[NSArray arrayWithObjects:
                                                                             [GCNode nodeWithTag:[GCTag tagCoded:@"DATE"]
                                                                                                           value:@"1 JAN 1901"],
                                                                              nil]
                                                                             ],
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"DEAT"] 
                                                              value:@"Y"],
                                                 nil]];
    
    GCEntity *object = [GCEntity entityWithGedcomNode:node];
    
    STAssertEqualObjects([[object gedcomNode] gedcomString], 
                         @"0 @INDI2@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y"
                         , nil);
}

- (void)testObjectValues
{
    GCAttribute *date = [GCAttribute attributeWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    STAssertEqualObjects([date stringValue], @"1 JAN 1901", nil);
}

@end
