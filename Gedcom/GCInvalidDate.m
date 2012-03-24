//
//  GCInvalidDate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCInvalidDate.h"

@implementation GCInvalidDate

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setString:[coder decodeObjectForKey:@"string"]];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self string] forKey:@"string"];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCInvalidDate '%@']", [self string]];
}

-(NSString *)gedcomString
{
	return [self string];
}

- (GCInvalidDate *)copyWithZone:(NSZone *)zone
{
	GCInvalidDate *date = [[GCInvalidDate alloc] init];
	
	[date setString:[self string]];
	
	return date;
}

- (GCSimpleDate *)refDate
{
	return nil;
}

- (NSCalendar *)calendar
{
	return nil;
}

@synthesize string;

@end
