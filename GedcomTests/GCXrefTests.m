//
//  GCXrefTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <Gedcom/Gedcom.h>

@interface GCXrefTests : SenTestCase

@end

@implementation GCXrefTests

- (void)testSortByXref
{
    NSString *gedcomString =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @INDI4@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"0 @INDI3@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Peder /Hansen/\n"
    @"0 TRLR";
    
    GCContext *ctx = [GCContext context];
    
    NSError *error = nil;
    
    BOOL succeeded = [ctx parseData:[gedcomString dataUsingEncoding:NSASCIIStringEncoding] error:&error];
    
    STAssertTrue(succeeded, nil);
    STAssertNil(error, nil);
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    NSString *expected =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Peder /Hansen/\n"
    @"0 @INDI3@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"0 @INDI4@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"0 TRLR";
    
    [ctx _sortByXrefs];
    
    STAssertEqualObjects(ctx.gedcomString, expected, nil);
}

- (void)testRenumberXrefs
{
    NSString *gedcomString =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @i6@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"0 @I1@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"0 @abc123@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Peder /Hansen/\n"
    @"0 TRLR";
    
    GCContext *ctx = [GCContext context];
    
    NSError *error = nil;
    
    BOOL succeeded = [ctx parseData:[gedcomString dataUsingEncoding:NSASCIIStringEncoding] error:&error];
    
    STAssertTrue(succeeded, nil);
    STAssertNil(error, nil);
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    NSString *expected =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Peder /Hansen/\n"
    @"0 @INDI3@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"0 @INDI4@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"0 TRLR";
    
    [ctx _sortByXrefs];
    [ctx _renumberXrefs];
    
    STAssertEqualObjects(ctx.gedcomString, expected, nil);
}

@end
