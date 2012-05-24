//
//  GCPlacestringTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 24/05/12.
//  Copyright 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCPlacestringTests : SenTestCase
@end


@implementation GCPlacestringTests

- (void)testPlacestring
{
    NSMutableArray *placeStrings = [NSMutableArray array];
    
    GCPlacestring *a = [GCPlacestring valueWithGedcomString:@"Fuglafjør∂ur, Eysturoy, Eysturoyar sýsla, Færøerne"];
    GCPlacestring *b = [GCPlacestring valueWithGedcomString:@"Gilleleje Sogn, Holbo Herred, Frederiksborg Amt, Danmark"];
    GCPlacestring *c = [GCPlacestring valueWithGedcomString:@"Løvel Sogn, Nørlyng Herred, Viborg Amt, Danmark"];
    GCPlacestring *d = [GCPlacestring valueWithGedcomString:@"Græsted Sogn, Holbo Herred, Frederiksborg Amt, Danmark"];
    
    [placeStrings addObject:a];
    [placeStrings addObject:b];
    [placeStrings addObject:c];
    [placeStrings addObject:d];
    
    [placeStrings sortUsingSelector:@selector(compare:)];
    
    NSArray *expectedOrder = [NSArray arrayWithObjects:b, d, c, a, nil];
    
    STAssertEqualObjects(placeStrings, expectedOrder, nil);
}

@end