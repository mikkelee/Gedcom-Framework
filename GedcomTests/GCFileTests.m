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
	
	GCFile *file = [GCFile fileWithGedcomNodes:nodes];
    
    NSError *error = nil;
    
    BOOL result = [file validateFile:&error];
    
    STAssertTrue(result, nil);
    STAssertNil(error, nil);
}

- (void)testFileAtPath:(NSString *)path
{
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *gc_inputLines = [NSMutableArray array];
    
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [gc_inputLines addObject:line];
    }];
    
    NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
    
    GCFile *file = [GCFile fileWithGedcomNodes:nodes];
    
    NSMutableArray *gc_outputLines = [NSMutableArray arrayWithCapacity:3];
    for (GCNode *node in [file gedcomNodes]) {
        [gc_outputLines addObjectsFromArray:[node gedcomLines]];
    }
    
    //STAssertEqualObjects([NSSet setWithArray:nodes], [NSSet setWithArray:[file gedcomNodes]], nil);
    
    //NSLog(@"file: %@", [gc_outputLines componentsJoinedByString:@"\n"]);
    
    int errorCount = 0;
    for (int i = 0; i < [gc_outputLines count]; i++) {
        //NSLog(@"test: %@ - %@", [gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i]);
        STAssertEqualObjects([gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i], nil);
        if (![[gc_inputLines objectAtIndex:i] isEqualTo:[gc_outputLines objectAtIndex:i]] && ++errorCount > 100) {
            break;
        }
    }
}

- (void)testSimpleGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
    
    [self testFileAtPath:path];
}

- (void)AtestAllGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"allged" ofType:@"ged"];
    
    [self testFileAtPath:path];
}

- (void)AtestPrivate
{
    NSString *path = @"/Volumes/raid/Genealogy/Database 20120424.gedpkg/Database.ged";
    
    [self testFileAtPath:path];
}

@end
