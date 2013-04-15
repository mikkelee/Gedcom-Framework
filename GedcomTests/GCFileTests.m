//
//  GCFileTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

#import "CharacterSetHelpers.h"

@interface GCFileTests : SenTestCase 
@end

@implementation GCFileTests

- (void)testFile:(NSString *)path expectedEncoding:(GCFileEncoding)expectedEncoding
{
    // open file:
    
	GCContext *ctx = [GCContext context];
    
    [ctx readContentsOfFile:path error:nil];
    
    STAssertFalse(ctx.fileEncoding == GCUnknownFileEncoding, nil);
    
    // get pure nodes directly from file using encoding arrived at in context:
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *fileContents = nil;
    
    if (ctx.fileEncoding == GCANSELFileEncoding) {
        fileContents = stringFromANSELData(data);
    } else {
        fileContents = [[NSString alloc] initWithData:data encoding:ctx.fileEncoding];
    }
    
    NSArray *inputNodes = [GCNodeParser arrayOfNodesFromString:fileContents];
    
    // validate encoding:
    
    STAssertEquals(ctx.fileEncoding, expectedEncoding, nil);
    
    // validate file:
    
    NSError *error = nil;
    
    BOOL result = [ctx validateContext:&error];
    
    STAssertTrue(result, nil);
    
    if (!result) {
        NSLog(@"error: %@", error);
    }
    
    STAssertNil(error, nil);
    
    // determine that pure nodes and context output are equivalent:
    
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
        NSLog(@"leftoverOutput: %@", leftoverOutput);
    }
    
    NSData *ctxData = [NSKeyedArchiver archivedDataWithRootObject:ctx];
    
    GCContext *decodedCtx = [NSKeyedUnarchiver unarchiveObjectWithData:ctxData];
    
    //NSLog(@"ctx: %@", ctx.gedcomString);
    //NSLog(@"decodedCtx: %@", decodedCtx.gedcomString);
    
    STAssertTrue([ctx isEqualTo:decodedCtx], nil);
}

- (void)testSimpleGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
    
    [self testFile:path expectedEncoding:GCASCIIFileEncoding];
}

- (void)testAllGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"allged" ofType:@"ged"];
    
    [self testFile:path expectedEncoding:GCASCIIFileEncoding];
}

- (void)AtestTortureGed
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TGC55" ofType:@"ged"];
    
    [self testFile:path expectedEncoding:GCANSELFileEncoding];
}

- (void)AtestPrivate
{
    NSString *path = @"/Volumes/raid/Genealogy/dev/Gedcom/Database.ged";
    
    [self testFile:path expectedEncoding:GCUTF8FileEncoding];
}



@end
