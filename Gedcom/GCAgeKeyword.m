//
//  GCAgeKeyword.m
//  GCCoreData copy
//
//  Created by Mikkel Eide Eriksen on 08/06/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAgeKeyword.h"
#import "GCSimpleAge.h"

@implementation GCAgeKeyword

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setKeyword:[coder decodeObjectForKey:@"keyword"]];
    }
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self keyword] forKey:@"keyword"];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCAgeKeyword '%@']", [self keyword]];
}

-(NSString *)gedcomString
{
	return [self keyword];
}

- (GCAgeKeyword *)copyWithZone:(NSZone *)zone
{
	GCAgeKeyword *age = [[GCAgeKeyword alloc] init];
	
	[age setKeyword:[self keyword]];
	
	return age;
}

/*
 CHILD = age < 8 years 
 INFANT = age < 1 year 
 STILLBORN = died just prior, at, or near birth, 0 years 
 */
- (GCSimpleAge *)refAge
{
	GCSimpleAge *m = [[GCSimpleAge alloc] init];
    
    NSDateComponents *ageComponents = [[NSDateComponents alloc] init]; 
    
    if ([[self keyword] isEqualToString:@"CHILD"]) {
        [ageComponents setYear:8];
    } else if ([[self keyword] isEqualToString:@"INFANT"]) {
        [ageComponents setYear:1];
    } else if ([[self keyword] isEqualToString:@"STILLBORN"]) {
        [ageComponents setYear:0];
    } else {
        //TODO error!!
    }
    
	[m setAgeComponents:ageComponents];
    
    return m;
}

@synthesize keyword;

@end
