//
//  GCSanityCheckTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCSanityCheckTests : SenTestCase
@end

@implementation GCSanityCheckTests

-(void)testIndividualSanity
{
	GCContext *ctx = [GCContext context];
	
	GCIndividualRecord *indi = [GCIndividualRecord individualInContext:ctx];
	[indi addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[indi addAttributeWithType:@"sex" value:[GCGender maleGender]];
    
	GCBirthAttribute *birt = [GCBirthAttribute birth];
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    [indi.mutableProperties addObject:birt];
    
	GCDeathAttribute *deat = [GCDeathAttribute death];
	[deat addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1801"]];
    [indi.mutableProperties addObject:deat];
    
    NSError *error = nil;
    
    BOOL isSane = [indi sanityCheck:&error];
    
    STAssertFalse(isSane, nil);
    
    STAssertEquals([error code], GCSanityCheckInconsistency, nil);
    STAssertEqualObjects([error localizedDescription], @"birth usually occurs before death", nil);
}

@end
