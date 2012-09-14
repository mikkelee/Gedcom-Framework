//
//  GCNodeTests.m
//  Gedcom
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
	
    int errorCount = 0;
	for (int i = 0; i < [gc_outputLines count]; i++) {
		STAssertEqualObjects([gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i], nil);
        if (![[gc_inputLines objectAtIndex:i] isEqualTo:[gc_outputLines objectAtIndex:i]] && ++errorCount > 100) {
            break;
        }
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
    
    mutableNode.gedValue = @"Jens /Hansen/ Smed";
    
    STAssertEqualObjects([mutableNode gedValue], @"Jens /Hansen/ Smed", nil);
    
    GCMutableNode *nickname = [GCMutableNode nodeWithTag:@"NICK" value:@"Smeden"];
    
    STAssertEquals([[mutableNode subNodes] count], (NSUInteger)0, nil);

    [[mutableNode subNodes] addObject:nickname];
    
    STAssertEquals([[mutableNode subNodes] count], (NSUInteger)1, nil);
}

- (void)testConcatenation
{
    NSString *gedcom = 
    @"0 @N1@ NOTE\n"
    @"1 CONT abc\n"
    @"1 CONC def\n"
    @"1 CONC ghi\n"
    @"1 CONT A very very long line that needs to be broken up because it is more than 248 characters long resulting in some CONC nodes underneath the current node. They should be assembled and disassembled losslessly by the GCNode code without need for program\n"
    @"1 CONC mer- or user-intervention."
    ;
	[self testGedString:gedcom countShouldBe:1];
}

@end
