//
//  GCTransactionTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <Gedcom/Gedcom.h>
#import "GCContext_internal.h"

@interface GCTransactionTests : SenTestCase

@end

@implementation GCTransactionTests

- (void)testTransaction
{
	GCContext *ctx = [GCContext context];
	
	GCIndividualEntity *indi = [GCIndividualEntity individualInContext:ctx];
	[indi addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[indi addAttributeWithType:@"sex" value:[GCGender maleGender]];
    
    NSDate *knownDate = [NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00 +0000"];
    [indi setValue:knownDate forKey:@"modificationDate"];
    
    STAssertEqualObjects([indi gedcomString],
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
    [ctx beginTransaction];
    
    [indi addAttributeWithType:@"birth" value:[GCBool yes]];
    
    [indi setValue:knownDate forKey:@"modificationDate"];
    
    STAssertEqualObjects([indi gedcomString],
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
						 @"1 BIRT Y\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
    [ctx rollback];
    
    STAssertEqualObjects([indi gedcomString],
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
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
    @"1 NAME Jens /Hansen/\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"0 @INDI3@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"0 @INDI4@ INDI\n"
    @"1 NAME Peder /Hansen/\n"
    @"0 TRLR";
    
    [ctx _renumberXrefs];

    STAssertEqualObjects(ctx.gedcomString, expected, nil);
}

@end
