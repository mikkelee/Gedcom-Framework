//
//  GCTransactionTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <Gedcom/Gedcom.h>

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

@end
