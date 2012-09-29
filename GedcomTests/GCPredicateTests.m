//
//  GCPredicateTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCPredicateTests : SenTestCase
@end

@implementation GCPredicateTests

- (void)testPredicates
{
    GCContext *ctx = [[GCContext alloc] init];
    
    NSString *gedcomString =
    @"0 HEAD\n"
    @"0 @I1@ INDI\n"
    @"1 NAME Jens /Hansen/\n"
    @"1 SEX M\n"
    @"1 BIRT\n"
    @"2 DATE 1 JAN 1901\n"
    @"2 PLAC Copenhagen, Denmark\n"
    @"0 @I2@ INDI\n"
    @"1 NAME Hans /Jensen/\n"
    @"1 SEX M\n"
    @"1 DEAT\n"
    @"2 DATE 23 FEB 1910\n"
    @"2 PLAC Copenhagen, Denmark\n"
    @"0 @I3@ INDI\n"
    @"1 NAME Lars /Hansen/\n"
    @"1 SEX M\n"
    @"1 BIRT\n"
    @"2 DATE BEF 1898\n"
    @"2 PLAC Stockholm, Sweden\n"
    @"0 @I4@ INDI\n"
    @"1 SEX M\n"
    @"1 NAME Peder /Hansen/\n"
    @"1 BIRT\n"
    @"2 PLAC Stockholm, Sweden\n"
    @"2 DATE AFT 1905\n"
    @"0 TRLR";
    
    [ctx parseNodes:[GCNode arrayOfNodesFromString:gedcomString] error:nil];
    
    NSPredicate *birthPredicate = [NSPredicate predicateWithFormat:@"ANY births.date.value < %@", [GCDate valueWithGedcomString:@"1905"]];
    NSArray *birthResult = [ctx.individuals filteredArrayUsingPredicate:birthPredicate];
    STAssertEquals([birthResult count], (NSUInteger)2, nil);
    
    NSPredicate *cphPredicate = [NSPredicate predicateWithFormat:@"ANY individualEvents.place.value.gedcomString BEGINSWITH %@", @"Copenhagen"];
    NSArray *cphResult = [ctx.individuals filteredArrayUsingPredicate:cphPredicate];
    STAssertEquals([cphResult count], (NSUInteger)2, nil);
    
    NSPredicate *hansenPredicate = [NSPredicate predicateWithFormat:@"ANY personalNames.value.gedcomString CONTAINS %@", @"Hansen"];
    NSArray *hansenResult = [ctx.individuals filteredArrayUsingPredicate:hansenPredicate];
    STAssertEquals([hansenResult count], (NSUInteger)3, nil);
    
}

@end
