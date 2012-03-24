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

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setSimpleDate:[coder decodeObjectForKey:@"simpleDate"]];
        [self setPhrase:[coder decodeObjectForKey:@"phrase"]];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self simpleDate] forKey:@"simpleDate"];
	[coder encodeObject:[self phrase] forKey:@"phrase"];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCInterpretedDate %@ %@]", [self simpleDate], [self phrase]];
}

-(NSString *)gedcomString
{
	return [NSString stringWithFormat:@"INT %@ (%@)]", [[self simpleDate] gedcomString], [[self phrase] gedcomString]];
}

- (GCInterpretedDate *)copyWithZone:(NSZone *)zone
{
	GCInterpretedDate *date = [[GCInterpretedDate alloc] init];
	
	[date setSimpleDate:[self simpleDate]];
	[date setPhrase:[self phrase]];
	
	return date;
}

@synthesize phrase;

@end
