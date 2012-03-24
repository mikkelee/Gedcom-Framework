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
    
    //NOTE may randomly fail until node order is enforced; also needs to be corrected below
    STAssertEqualObjects([[indi gedcomNode] gedcomString], 
                         @"0 INDI\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901", nil);
}

@end
