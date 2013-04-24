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
	
	GCIndividualRecord *indi = [GCIndividualRecord individualInContext:ctx];
	[indi addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[indi addAttributeWithType:@"sex" value:[GCGender maleGender]];
    
    NSDate *knownDate = [NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00 +0000"];
    [indi setValue:knownDate forKey:@"modificationDate"];
    
    STAssertEqualObjects(indi.gedcomString,
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
    
    STAssertEqualObjects(indi.gedcomString,
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
						 @"1 BIRT Y\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
    [ctx rollback];
    
    STAssertEqualObjects(indi.gedcomString,
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
}

- (void)testMerge
{
    NSString *gedcomStringA =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @INDI3@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"1 SEX M\n"
    @"1 FAMS @fam@\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"1 SEX M\n"
    @"1 FAMC @fam@\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"1 SEX M\n"
    @"0 @fam@ FAM\n"
    @"1 HUSB @INDI3@\n"
    @"1 CHIL @INDI2@\n"
    @"0 TRLR";
    
    GCContext *ctxA = [GCContext context];
    
    NSError *errorA = nil;
    
    BOOL succeededA = [ctxA parseData:[gedcomStringA dataUsingEncoding:NSASCIIStringEncoding] error:&errorA];
    
    STAssertTrue(succeededA, nil);
    STAssertNil(errorA, nil);
    if (errorA) {
        NSLog(@"errorA: %@", errorA);
    }
    
    NSString *gedcomStringB =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Tom /Larsen/\n"
    @"1 SEX M\n"
    @"1 FAMC @fam@\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"1 SEX M\n"
    @"1 FAMS @fam@\n"
    @"0 @fam@ FAM\n"
    @"1 HUSB @INDI2@\n"
    @"1 CHIL @INDI1@\n"
    @"0 TRLR";
    
    GCContext *ctxB = [GCContext context];
    
    NSError *errorB = nil;
    
    BOOL succeededB = [ctxB parseData:[gedcomStringB dataUsingEncoding:NSASCIIStringEncoding] error:&errorB];
    
    STAssertTrue(succeededB, nil);
    STAssertNil(errorB, nil);
    if (errorB) {
        NSLog(@"errorB: %@", errorB);
    }
    
    NSError *errorM = nil;
    
    BOOL succeededM = [ctxA mergeContext:ctxB error:&errorM];
    
    STAssertTrue(succeededM, nil);
    STAssertNil(errorM, nil);
    if (errorM) {
        NSLog(@"errorM: %@", errorM);
    }

    NSString *expected =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @FAM1@ FAM\n"
    @"1 HUSB @INDI3@\n"
    @"1 CHIL @INDI2@\n"
    @"0 @FAM2@ FAM\n"
    @"1 HUSB @INDI5@\n"
    @"1 CHIL @INDI4@\n"
    @"0 @INDI1@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"1 SEX M\n"
    @"0 @INDI2@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"1 SEX M\n"
    @"1 FAMC @FAM1@\n"
    @"0 @INDI3@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"1 SEX M\n"
    @"1 FAMS @FAM1@\n"
    @"0 @INDI4@ INDI\n"
    @"1 NAME Tom /Larsen/\n"
    @"1 SEX M\n"
    @"1 FAMC @FAM2@\n"
    @"0 @INDI5@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"1 SEX M\n"
    @"1 FAMS @FAM2@\n"
    @"0 TRLR";
    
    STAssertEqualObjects(ctxA.gedcomString, expected, nil);
}

@end
