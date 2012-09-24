//
//  GCFileTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCFileTests : SenTestCase 
@end

@implementation GCFileTests

- (void)testFileValidation
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
	
	GCContext *ctx = [GCContext contextWithGedcomNodes:nodes];
    
    NSError *error = nil;
    
    BOOL result = [ctx validateContext:&error];
    
    STAssertTrue(result, nil);
    
    if (!result) {
        NSLog(@"error: %@", error);
    }
    
    STAssertNil(error, nil);
}

- (void)testFileAtPath:(NSString *)path
{
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *gc_inputLines = [NSMutableArray array];
    
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [gc_inputLines addObject:line];
    }];
    
    NSArray *inputNodes = [GCNode arrayOfNodesFromString:fileContents];
    
	GCContext *ctx = [GCContext contextWithGedcomNodes:inputNodes];
    
    // validate file:
    
    NSError *error = nil;
    
    BOOL result = [ctx validateContext:&error];
    
    STAssertTrue(result, nil);
    
    if (!result) {
        NSLog(@"error: %@", error);
    }
    
    STAssertNil(error, nil);
    
    // determine that input and output are equivalent:
    
    NSArray *outputNodes = ctx.gedcomNodes;
    
    NSMutableArray *leftoverInput = [inputNodes mutableCopy];
    NSMutableArray *leftoverOutput = [outputNodes mutableCopy];
    
    for (GCNode *inputNode in inputNodes) {
        GCNode *matchingInputNode = nil;
        GCNode *matchingOutputNode = nil;
        
        for (GCNode *outputNode in leftoverOutput) {
            if ([inputNode isEquivalentTo:outputNode]) {
                matchingInputNode = inputNode;
                matchingOutputNode = outputNode;
                break;
            }
        }
        
        if (matchingInputNode) {
            [leftoverInput removeObject:matchingInputNode];
            [leftoverOutput removeObject:matchingOutputNode];
        }
    }
    
    STAssertEquals([leftoverInput count], (NSUInteger)0, nil);
    STAssertEquals([leftoverOutput count], (NSUInteger)0, nil);
    
    if ([leftoverInput count] > 0) {
        NSLog(@"leftoverInput: %@", leftoverInput);
    }
    
    if ([leftoverOutput count] > 0) {
        NSLog(@"leftoverInput: %@", leftoverOutput);
    }
}

- (void)testSimpleGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
    
    [self testFileAtPath:path];
}

- (void)testAllGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"allged" ofType:@"ged"];
    
    [self testFileAtPath:path];
}

- (void)AtestPrivate
{
    NSString *path = @"/Volumes/raid/Genealogy/dev/Gedcom/Database.ged";
    
    [self testFileAtPath:path];
}

@end
