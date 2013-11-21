//
//  GCSimilarityTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/11/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCSimilarityTests : SenTestCase
@end

@implementation GCSimilarityTests

- (void)testSimilarity
{
    GCContext *ctx = [GCContext context];
	
	GCIndividualRecord *indi1 = [GCIndividualRecord individualInContext:ctx];
	[indi1 addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[indi1 addAttributeWithType:@"sex" value:[GCGender unknownGender]];
    
	GCBirthAttribute *birt = [GCBirthAttribute birth];
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    [indi1.mutableProperties addObject:birt];
    
	GCDeathAttribute *deat = [GCDeathAttribute death];
	[deat addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"12 SEP 1950"]];
    [indi1.mutableProperties addObject:deat];
    
	GCIndividualRecord *indi2 = [GCIndividualRecord individualInContext:ctx];
	[indi2 addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"]];
	[indi2 addAttributeWithType:@"sex" value:[GCGender maleGender]];
    
	GCBirthAttribute *birt2 = [GCBirthAttribute birth];
	[birt2 addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1901"]];
    [indi2.mutableProperties addObject:birt2];
    
	GCBirthAttribute *birt3 = [GCBirthAttribute birth];
	[birt3 addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1902"]];
    [indi2.mutableProperties addObject:birt3];
    
    GCSimilarity res1 = [indi1 similarityTo:indi2];
    GCSimilarity res2 = [indi2 similarityTo:indi1];
    
    STAssertEquals(res1, res2, nil);
}

@end
