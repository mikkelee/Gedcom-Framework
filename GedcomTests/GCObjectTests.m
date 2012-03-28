//
//  GCObjectTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCObjectTests : SenTestCase {
	
}

@end

@implementation GCObjectTests

- (void)testObjectValues
{
	GCContext *ctx = [[GCContext alloc] init];
	
    GCAttribute *date = [GCAttribute attributeWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"] inContext:ctx];
    
    STAssertEqualObjects([date stringValue], @"1 JAN 1901", nil);
}

- (void)testSimpleObjects
{
	GCContext *ctx = [[GCContext alloc] init];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual" inContext:ctx];
	
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
	GCAttribute *birt = [GCAttribute attributeWithType:@"Birth" inContext:ctx];
    
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
    
    GCEntity *object = [GCEntity entityWithGedcomNode:node inContext:ctx];
    
    STAssertEqualObjects([[object gedcomNode] gedcomString], 
                         @"0 @INDI2@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y"
                         , nil);
}

- (void)testRelationships
{
	GCContext *ctx = [[GCContext alloc] init];
	
    GCEntity *fam = [GCEntity entityWithType:@"Family" inContext:ctx];
	
	GCEntity *husb = [GCEntity entityWithType:@"Individual" inContext:ctx];
	
	[husb addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	
	GCEntity *wife = [GCEntity entityWithType:@"Individual" inContext:ctx];
	
	[wife addAttributeWithType:@"Name" stringValue:@"Anne /Larsdatter/"];
	
	GCEntity *chil = [GCEntity entityWithType:@"Individual" inContext:ctx];
	
	[wife addAttributeWithType:@"Name" stringValue:@"Hans /Jensen/"];
	
	[fam addRelationshipWithType:@"Husband" target:husb];
	[fam addRelationshipWithType:@"Wife" target:wife];
	[fam addRelationshipWithType:@"Child" target:chil];
	
    STAssertEqualObjects([[fam gedcomNode] gedcomString], 
                         @"0 @FAM1@ FAM\n"
                         @"1 HUSB @INDI1@\n"
                         @"1 WIFE @INDI2@\n"
                         @"1 CHIL @INDI3@"
                         , nil);
	
    STAssertEqualObjects([[husb gedcomNode] gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 FAMS @FAM1@"
                         , nil);
	
    STAssertEqualObjects([[wife gedcomNode] gedcomString], 
                         @"0 @INDI2@ INDI\n"
                         @"1 NAME Anne /Larsdatter/\n"
						 @"1 FAMS @FAM1@"
                         , nil);
	
    STAssertEqualObjects([[wife gedcomNode] gedcomString], 
                         @"0 @INDI3@ INDI\n"
                         @"1 NAME Hans /Jensen/\n"
						 @"1 FAMC @FAM1@"
                         , nil);
}

@end
