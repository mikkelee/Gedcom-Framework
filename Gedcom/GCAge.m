//
//  GCAge.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAge.h"
#import "GCAgeParser.h"

#pragma mark Private methods

@class GCSimpleAge;

@interface GCAge ()

@property (retain, readonly) GCSimpleAge *refAge; //used for sorting, etc.

@end

#pragma mark -
#pragma mark Concrete subclasses
#pragma mark -

#pragma mark GCSimpleAge

@interface GCSimpleAge : GCAge

@property (copy) NSDateComponents *ageComponents;

@end

@implementation GCSimpleAge

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCSimpleAge (%d years, %d months, %d days)]", [[self ageComponents] year], [[self ageComponents] month], [[self ageComponents] day]];
}

- (NSString *)gedcomString
{
	NSString *months = @"";
	if ([[self ageComponents] month] >= 1) {
		months = [NSString stringWithFormat:@" %@", [[self ageComponents] month]];
	}
	
	NSString *days = @"";
	if ([[self ageComponents] day] >= 1) {
		days = [NSString stringWithFormat:@" %dd", [[self ageComponents] day]];
	}
	
	return [NSString stringWithFormat:@"%dy%@%@", [[self ageComponents] year], months, days];
}

- (GCSimpleAge *)refAge
{
	return self;
}

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleAge class]]) {
		if ([[self ageComponents] year] != [[other ageComponents] year]) {
			return [[NSNumber numberWithInt:[[self ageComponents] year]] compare:[NSNumber numberWithInt:[[other ageComponents] year]]];
		} else if ([[self ageComponents] month] != [[other ageComponents] month]) {
			return [[NSNumber numberWithInt:[[self ageComponents] month]] compare:[NSNumber numberWithInt:[[other ageComponents] month]]];
		} else {
			return [[NSNumber numberWithInt:[[self ageComponents] day]] compare:[NSNumber numberWithInt:[[other ageComponents] day]]];
		}
	} else {
		return [self compare:[other refAge]];
	}
}

@synthesize ageComponents;

@end

#pragma mark GCQualifiedAge

@interface GCQualifiedAge : GCAge

@property (copy) GCAge * age;
@property (assign) GCAgeQualifier qualifier;

@end

@implementation GCQualifiedAge

NSString * const GCAgeQualifier_toString[] = {
    @"<",
    @">"
};

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCQualifiedAge %@ %@]", GCAgeQualifier_toString[[self qualifier]], [self age]];
}

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", GCAgeQualifier_toString[[self qualifier]], [self age]];
}

- (GCSimpleAge *)refAge
{
	return [[self age] refAge];
}

@synthesize age;
@synthesize qualifier;

@end

#pragma mark GCAgeKeyword

@interface GCAgeKeyword : GCAge

@property (copy) NSString *keyword;

@end

@implementation GCAgeKeyword

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCAgeKeyword '%@']", [self keyword]];
}

-(NSString *)gedcomString
{
	return [self keyword];
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

#pragma mark GCInvalidAge

@interface GCInvalidAge : GCAge

@property (copy) NSString *string;

@end

@implementation GCInvalidAge

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCInvalidAge '%@']", [self string]];
}

-(NSString *)gedcomString
{
	return [self string];
}

- (GCSimpleAge *)refAge
{
	GCSimpleAge *m = [[GCSimpleAge alloc] init];
    
	[m setAgeComponents:[[NSDateComponents alloc] init]];
    
    return m;
}

@synthesize string;

@end

#pragma mark -
#pragma mark Placeholder class
#pragma mark -

@interface GCPlaceholderAge : GCAge
@end

@implementation GCPlaceholderAge

- (id)initWithSimpleAge:(NSDateComponents *)c;
{
	id age = [[GCSimpleAge alloc] init];
	
	[age setAgeComponents:c];
	
	return age;
}

- (id)initWithAgeKeyword:(NSString *)s
{
	id age = [[GCAgeKeyword alloc] init];
	
	[age setKeyword:s];
	
	return age;
}

- (id)initWithInvalidAgeString:(NSString *)s
{
	id age = [[GCInvalidAge alloc] init];
	
	[age setString:s];
	
	return age;
}

- (id)initWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
	id age = [[GCQualifiedAge alloc] init];
	
	[age setAge:a];
	[age setQualifier:q];
	
	return age;
}

@end

#pragma mark -

@implementation GCAge

#pragma mark Initialization

+ (id)allocWithZone:(NSZone *)zone
{
    if ([GCAge self] == self)
        return [GCPlaceholderAge allocWithZone:zone];    
    return [super allocWithZone:zone];
}

- (id)initWithSimpleAge:(NSDateComponents *)c
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithAgeKeyword:(NSString *)s
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithInvalidAgeString:(NSString *)s
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

#pragma mark Convenience constructors

+ (id)ageFromGedcom:(NSString *)gedcom
{
	return [[GCAgeParser sharedAgeParser] parseGedcom:gedcom];
}

+ (id)ageWithSimpleAge:(NSDateComponents *)c;
{
	return [[self alloc] initWithSimpleAge:c];
}

+ (id)ageWithAgeKeyword:(NSString *)s
{
	return [[self alloc] initWithAgeKeyword:s];
}

+ (id)ageWithInvalidAgeString:(NSString *)s
{
	return [[self alloc] initWithInvalidAgeString:s];
}

+ (id)ageWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
	return [[self alloc] initWithAge:a withQualifier:q];
}

-(NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refAge] compare:[other refAge]];
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        //[self setAgeComponents:[coder decodeObjectForKey:@"components"]];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self gedcomString] forKey:@"gedcomString"];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
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
