//
//  GCInterpretedDate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCInterpretedDate.h"
#import "GCSimpleDate.h"
#import "GCDatePhrase.h"

@implementation GCInterpretedDate

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCInterpretedDate %@ %@]", [self simpleDate], [self phrase]];
}

-(NSString *)gedcomString
{
	return [NSString stringWithFormat:@"INT %@ (%@)]", [[self simpleDate] gedcomString], [[self phrase] gedcomString]];
}

@synthesize phrase;

@end
