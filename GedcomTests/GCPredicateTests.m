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
    NSString *gedcomString =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
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
    @"2 DATE AFT 1905\n"
    @"2 PLAC Stockholm, Sweden\n"
    @"0 TRLR";
    
    GCContext *ctx = [GCContext context];
    
    NSError *error = nil;
    
    BOOL succeeded = [ctx parseData:[gedcomString dataUsingEncoding:NSASCIIStringEncoding] error:&error];
    
    STAssertTrue(succeeded, nil);
    STAssertNil(error, nil);
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    NSPredicate *birthPredicate = [NSPredicate predicateWithFormat:@"ANY births.date.value < %@", [GCDate valueWithGedcomString:@"1905"]];
    NSArray *birthResult = [ctx.individuals filteredArrayUsingPredicate:birthPredicate];
    STAssertEquals([birthResult count], (NSUInteger)2, nil);
    
    NSPredicate *cphPredicate = [NSPredicate predicateWithFormat:@"ANY individualEvents.place.value.gedcomString BEGINSWITH %@", @"Copenhagen"];
    NSArray *cphResult = [ctx.individuals filteredArrayUsingPredicate:cphPredicate];
    STAssertEquals([cphResult count], (NSUInteger)2, nil);
    
    NSPredicate *hansenPredicate = [NSPredicate predicateWithFormat:@"ANY personalNames.value.gedcomString CONTAINS %@", @"Hansen"];
    NSArray *hansenResult = [ctx.individuals filteredArrayUsingPredicate:hansenPredicate];
    STAssertEquals([hansenResult count], (NSUInteger)3, nil);
    
    // TODO entire keypath MUST be non-null for predicate to work. how to avoid [NSNull compare:]?? something like this perhaps:
    //NSPredicate *birthPredicate = [NSPredicate predicateWithFormat:@"(SUBQUERY(births, $x, $x != nil && $x.date.value < %@).@count != 0)", [GCDate valueWithGedcomString:@"1905"]];
}

@end
