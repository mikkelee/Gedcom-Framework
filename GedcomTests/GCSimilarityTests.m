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
	[indi1 addAttributeWithType:@"sex" value:[GCGender maleGender]];
    
	GCIndividualRecord *indi2 = [GCIndividualRecord individualInContext:ctx];
	[indi2 addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"]];
	[indi2 addAttributeWithType:@"sex" value:[GCGender maleGender]];
    
    GCSimilarity res1 = [indi1 similarityTo:indi2];
    GCSimilarity res2 = [indi2 similarityTo:indi1];
    
    STAssertEquals(res1, res2, nil);
}

@end
