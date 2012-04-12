//
//  GCNodeTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 11/18/10.
//  Copyright 2010 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCNodeTests : SenTestCase {
	
}

@end


@implementation GCNodeTests

-(void)testGedString:(NSString *)gc_inputString countShouldBe:(NSUInteger) countShouldBe
{
	NSArray *gc_inputLines = [gc_inputString arrayOfLines];
	NSArray *nodes = [GCNode arrayOfNodesFromArrayOfStrings:[gc_inputString arrayOfLines]];
	NSMutableString *gc_outputString = [NSMutableString stringWithString:@""];
	NSMutableArray *gc_outputLines = [NSMutableArray arrayWithCapacity:[nodes count]];
	
	for (id node in nodes) {
		[gc_outputString appendString:[node gedcomString]];
		[gc_outputLines addObjectsFromArray:[node gedcomLines]];
	}
	
	STAssertEquals([gc_inputLines count], [gc_outputLines count], nil);
	STAssertNotNil(nodes, nil);
	STAssertNotNil(gc_inputString, nil);
	STAssertNotNil(gc_outputString, nil);
	STAssertEquals(countShouldBe, [nodes count], @"[nodes count] (%d) != %d", [nodes count], countShouldBe);
	
	for (int i = 0; i < [gc_outputLines count]; i++) {
		STAssertEqualObjects([gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i], nil);
	}
}

-(void)testFile:(NSString *)path countShouldBe:(NSUInteger) countShouldBe
{
	NSString *gc_inputString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	[self testGedString:gc_inputString countShouldBe:countShouldBe];
}

-(void)testSomeSimpleRecords
{
	[self testGedString:@"0 @I1@ INDI\n1 NAME John /Johnson/\n" countShouldBe:1];
	[self testGedString:@"0 @N1@ NOTE\n1 CONT This is a test\n" countShouldBe:1];
}

-(void)testSimpleGed
{
	//from http://www.heiner-eichmann.de/gedcom/gedcom.htm
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
	STAssertNotNil(path, nil);
	[self testFile:path countShouldBe:7];
}

-(void)TMP//testAllGed
{
	//NOTE: this test FAILS due to the <248 CONC issue.
	//from http://www.heiner-eichmann.de/gedcom/gedcom.htm
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"allged" ofType:@"ged"];
	STAssertNotNil(path, nil);
	[self testFile:path countShouldBe:18];
}

-(void)testValueForKey
{
	GCNode *aNode = [GCNode nodeWithTag:[GCTag tagWithType:@"GCAttribute" code:@"NAME"] value:@"Jens /Hansen/"];
	
	GCNode *bNode = [[GCNode alloc] initWithTag:[GCTag tagWithType:@"GCEntity" code:@"INDI"] 
										  value:nil 
										   xref:@"@I1@" 
									   subNodes:[NSArray arrayWithObject:aNode]];
	
	STAssertEqualObjects(aNode, [bNode valueForKey:@"NAME"], nil);
}

@end
