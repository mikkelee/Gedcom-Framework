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
    
    NSLog(@"test: %@", [[indi gedcomNode] gedcomString]);
}

@end
