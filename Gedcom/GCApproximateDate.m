//
//  GCDateApproximate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCApproximateDate.h"
#import "GCSimpleDate.h"

@implementation GCApproximateDate

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setSimpleDate:[coder decodeObjectForKey:@"simpleDate"]];
        [self setType:[coder decodeObjectForKey:@"type"]];
    }
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self type] forKey:@"type"];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCApproximateDate '%@' %@]", [self type], [self simpleDate]];
}

-(NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", [self type], [[self simpleDate] gedcomString]];
}

- (GCApproximateDate *)copyWithZone:(NSZone *)zone
{
	GCApproximateDate *date = [[GCApproximateDate alloc] init];
	
	[date setType:[self type]];
	[date setSimpleDate:[self simpleDate]];
	
	return date;
}

@synthesize type;

@end
