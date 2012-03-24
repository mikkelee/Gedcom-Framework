//
//  GCInvalidAge.m
//  GCCoreData copy
//
//  Created by Mikkel Eide Eriksen on 08/06/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCInvalidAge.h"
#import "GCSimpleAge.h"

@implementation GCInvalidAge

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
	return [NSString stringWithFormat:@"[GCInvalidAge '%@']", [self string]];
}

-(NSString *)gedcomString
{
	return [self string];
}

- (GCInvalidAge *)copyWithZone:(NSZone *)zone
{
	GCInvalidAge *age = [[GCInvalidAge alloc] init];
	
	[age setString:[self string]];
	
	return age;
}

- (GCSimpleAge *)refAge
{
	GCSimpleAge *m = [[GCSimpleAge alloc] init];
    
	[m setAgeComponents:[[NSDateComponents alloc] init]];
    
    return m;
}

@synthesize string;

@end
