//
//  GCNodeTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 11/18/10.
//  Copyright 2010 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCNodeTests : SenTestCase
@end


@implementation GCNodeTests

-(void)testGedString:(NSString *)gc_inputString countShouldBe:(NSUInteger) countShouldBe
{
	NSMutableArray *gc_inputLines = [NSMutableArray array];
    
    [gc_inputString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [gc_inputLines addObject:line];
    }];
    
	NSArray *nodes = [GCNode arrayOfNodesFromString:gc_inputString];
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

-(void)testAllGed
{
	//from http://www.heiner-eichmann.de/gedcom/gedcom.htm
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"allged" ofType:@"ged"];
	STAssertNotNil(path, nil);
	[self testFile:path countShouldBe:18];
}

- (void)testMutableNode
{
    GCNode *node = [GCNode nodeWithTag:@"NAME" value:@"Jens /Hansen/"];
    
    GCMutableNode *mutableNode = [node mutableCopy];
    
    [mutableNode setGedValue:@"Jens /Hansen/ Smed"];
    
    STAssertEqualObjects([mutableNode gedValue], @"Jens /Hansen/ Smed", nil);
    
    GCMutableNode *nickname = [GCMutableNode nodeWithTag:@"NICK" value:@"Smeden"];
    
    STAssertEquals([[mutableNode subNodes] count], (NSUInteger)0, nil);

    [mutableNode addSubNode:nickname];
    
    STAssertEquals([[mutableNode subNodes] count], (NSUInteger)1, nil);
}

@end
