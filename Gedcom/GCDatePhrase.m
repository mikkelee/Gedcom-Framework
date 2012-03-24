//
//  GCDatePhrase.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDatePhrase.h"

@implementation GCDatePhrase

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setPhrase:[coder decodeObjectForKey:@"phrase"]];
    }
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self phrase] forKey:@"phrase"];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCDatePhrase '%@']", [self phrase]];
}

-(NSString *)gedcomString
{
	return [NSString stringWithFormat:@"(%@)", [self phrase]];
}

- (GCDatePhrase *)copyWithZone:(NSZone *)zone
{
	GCDatePhrase *date = [[GCDatePhrase alloc] init];
	
	[date setPhrase:[self phrase]];
	
	return date;
}

- (NSCalendar *)calendar
{
	return nil;
}

- (GCSimpleDate *)refDate
{
	return nil;
}

@synthesize phrase;

@end
