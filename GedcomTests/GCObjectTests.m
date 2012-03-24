//
//  GCObjectTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

@interface GCObjectTests : SenTestCase {
	
}

@end

@implementation GCObjectTests

- (void)testObjects
{
    GCObject *indi = [GCObject objectWithType:@"Individual"];
    
    GCObject *name = [GCObject objectWithType:@"Name"];
    [name setStringValue:@"Jens /Hansen/"];
    
    [indi addRecord:name];
    
    GCObject *altName = [GCObject objectWithType:@"Name"];
    [altName setStringValue:@"Jens /Hansen/ Smed"];
    
    [indi addRecord:altName];
    
    GCObject *birt = [GCObject objectWithType:@"Birth"];
    GCObject *date = [GCObject objectWithType:@"Date"];
    [date setStringValue:@"1 JAN 1901"];
    
    [birt addRecord:date];
    [indi addRecord:birt];
    
    STAssertEqualObjects([[indi gedcomNode] gedcomString], 
                         @"0 @I1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901", nil);
    
    
    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagCoded:@"INDI"] 
                                         value:nil
                                          xref:@"@I1@"
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
                                                 nil]];
    
    GCObject *object = [GCObject objectWithGedcomNode:node];
    
    STAssertEqualObjects([[indi gedcomNode] gedcomString], 
                         [[object gedcomNode] gedcomString], nil);
}

@end
