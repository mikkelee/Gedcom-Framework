//
//  GCAge.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAge.h"
#import "GCAgeParser.h"
#import "GCQualifiedAge.h"
#import "GCSimpleAge.h"
#import "GCAgeKeyword.h"
#import "GCInvalidAge.h"

@implementation GCAge

+ (GCAge *)ageFromGedcom:(NSString *)gedcom
{
	return [[GCAgeParser sharedAgeParser] parseGedcom:gedcom];
}

+ (GCSimpleAge *)simpleAge:(NSDateComponents *)c;
{
	GCSimpleAge *age = [[GCSimpleAge alloc] init];
	
	[age setAgeComponents:c];
	
	return age;
}

+ (GCAgeKeyword *)ageKeyword:(NSString *)s
{
	GCAgeKeyword *age = [[GCAgeKeyword alloc] init];
	
	[age setKeyword:s];
	
	return age;
}

+ (GCInvalidAge *)invalidAgeString:(NSString *)s
{
	GCInvalidAge *age = [[GCInvalidAge alloc] init];
	
	[age setString:s];
	
	return age;
}

+ (GCQualifiedAge *)age:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
	GCQualifiedAge *age = [[GCQualifiedAge alloc] init];
	
	[age setAge:a];
	[age setQualifier:q];
	
	return age;
}

-(NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refAge] compare:[other refAge]];
	}
}

@dynamic refAge;

@dynamic gedcomString;
@dynamic displayString;
@dynamic description;

- (NSUInteger)years
{
    return [[[self refAge] ageComponents] year];
}

- (NSUInteger)months
{
    return [[[self refAge] ageComponents] month];
}

- (NSUInteger)days
{
    return [[[self refAge] ageComponents] day];
}

@end
