//
//  GCAge.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"
#import "GCAge_internal.h"
#import "Gedcom_internal.h"

#pragma mark -
#pragma mark Concrete subclasses
#pragma mark -

NSString * const GCAgeQualifier_toString[] = {
    @"<",
    @"",
    @">"
};

#pragma mark GCSimpleAge

@implementation GCSimpleAge

- (NSString *)gedcomString
{
    NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:3];
	
	if ([self.ageComponents year] >= 1) {
        [stringComponents addObject:[NSString stringWithFormat:@"%ldy", [self.ageComponents year]]];
    }
    
	if ([self.ageComponents month] >= 1) {
		[stringComponents addObject:[NSString stringWithFormat:@"%ldm", [self.ageComponents month]]];
	}
	
	if ([self.ageComponents day] >= 1) {
		[stringComponents addObject:[NSString stringWithFormat:@"%ldd", [self.ageComponents day]]];
	}
    
    if ([stringComponents count] == 0) {
        [stringComponents addObject:@"0y"];
    }
    
    return [NSString stringWithFormat:@"%@%@", GCAgeQualifier_toString[_qualifier], [stringComponents componentsJoinedByString:@" "]];
}

- (NSString *)displayString
{
    NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:3];
	
	if ([self.ageComponents year] == 1) {
		[stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d year", @"Values"), [self.ageComponents year]]];
	} else if ([self.ageComponents year] > 1) {
		[stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d years", @"Values"), [self.ageComponents year]]];
	}
    
	if ([self.ageComponents month] == 1) {
		[stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d month", @"Values"), [self.ageComponents month]]];
	} else if ([self.ageComponents month] > 1) {
		[stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d months", @"Values"), [self.ageComponents month]]];
	}
	
	if ([self.ageComponents day] == 1) {
		[stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d day", @"Values"), [self.ageComponents day]]];
	} else if ([self.ageComponents day] > 1) {
		[stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d days", @"Values"), [self.ageComponents day]]];
	}
    
    if ([stringComponents count] == 0) {
        [stringComponents addObject:[NSString stringWithFormat:GCLocalizedString(@"%d years", @"Values"), 0]];
    }
    
    return [NSString stringWithFormat:@"%@%@", GCAgeQualifier_toString[_qualifier], [stringComponents componentsJoinedByString:@", "]];
}

- (GCSimpleAge *)refAge
{
	return self;
}

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleAge class]]) {
		if ([self.ageComponents year] != [[other ageComponents] year]) {
			return [@([self.ageComponents year]) compare:@([[other ageComponents] year])];
		} else if ([self.ageComponents month] != [[other ageComponents] month]) {
			return [@([self.ageComponents month]) compare:@([[other ageComponents] month])];
		} else if ([self.ageComponents month] != [[other ageComponents] month]) {
			return [@([self.ageComponents day]) compare:@([[other ageComponents] day])];
		} else {
            return [@([self qualifier]) compare:@([other qualifier])];
        }
	} else {
		return [self compare:[other refAge]];
	}
}

@end

#pragma mark GCAgeKeyword

@implementation GCAgeKeyword

- (NSString *)gedcomString
{
    return [NSString stringWithFormat:@"%@%@", GCAgeQualifier_toString[_qualifier], [self keyword]];
}

- (NSString *)displayString
{
    return GCLocalizedString(self.gedcomString, @"Values");
}

/*
 CHILD = age < 8 years 
 INFANT = age < 1 year 
 STILLBORN = died just prior, at, or near birth, 0 years 
 */
- (id)refAge
{
    NSDateComponents *ageComponents = [[NSDateComponents alloc] init]; 
    
    GCAgeQualifier qualifier = GCAgeNoQualifier;
    
    [ageComponents setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    if ([self.keyword isEqualToString:@"CHILD"]) {
        [ageComponents setYear:8];
        qualifier = GCAgeLessThan;
    } else if ([self.keyword isEqualToString:@"INFANT"]) {
        [ageComponents setYear:1];
        qualifier = GCAgeLessThan;
    } else if ([self.keyword isEqualToString:@"STILLBORN"]) {
        [ageComponents setYear:0];
    } else {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidAgeKeywordException"
														 reason:[NSString stringWithFormat:@"Invalid AgeKeyword '%@'", [self keyword]]
													   userInfo:nil];
		@throw exception;
    }
    
    return [GCAge ageWithSimpleAge:ageComponents qualifier:qualifier];
}

@end

#pragma mark GCInvalidAge

@implementation GCInvalidAge

- (NSString *)gedcomString
{
	return self.string;
}

- (NSString *)displayString
{
    return self.gedcomString;
}

- (GCSimpleAge *)refAge
{
	GCSimpleAge *age = [[GCSimpleAge alloc] init];
    
	age.ageComponents = [[NSDateComponents alloc] init];
    
    return age;
}

@end

#pragma mark -
#pragma mark Placeholder class
#pragma mark -

@interface GCPlaceholderAge : GCAge
@end

@implementation GCPlaceholderAge

+ (instancetype)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedAgePlaceholder = nil;
    dispatch_once(&pred, ^{
        _sharedAgePlaceholder = [super allocWithZone:zone];
    });
    return _sharedAgePlaceholder;
}

- (instancetype)initWithSimpleAge:(NSDateComponents *)c qualifier:(GCAgeQualifier)q
{
	GCSimpleAge *age = [[GCSimpleAge alloc] init];
	
    [c setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
	age.ageComponents = c;
    age.qualifier = q;
	
	return (id)age;
}

- (instancetype)initWithAgeKeyword:(NSString *)s qualifier:(GCAgeQualifier)q
{
	GCAgeKeyword *age = [[GCAgeKeyword alloc] init];
	
    age.keyword = s;
    age.qualifier = q;
	
	return (id)age;
}

- (instancetype)initWithInvalidAgeString:(NSString *)s
{
	GCInvalidAge *age = [[GCInvalidAge alloc] init];
	
	age.string = s;
	
	return (id)age;
}

@end

#pragma mark -
#pragma mark Abstract class
#pragma mark -

@implementation GCAge

#pragma mark Initialization

+ (instancetype)allocWithZone:(NSZone *)zone
{
    if ([GCAge self] == self)
        return [GCPlaceholderAge allocWithZone:zone];    
    return [super allocWithZone:zone];
}

- (instancetype)initWithGedcom:(NSString *)gedcom
{
	return [[GCAgeParser sharedAgeParser] parseGedcom:gedcom];
}

//COV_NF_START
- (instancetype)initWithSimpleAge:(NSDateComponents *)c qualifier:(GCAgeQualifier)q
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (instancetype)initWithAgeKeyword:(NSString *)s qualifier:(GCAgeQualifier)q
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (instancetype)initWithInvalidAgeString:(NSString *)s
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}
//COV_NF_END

#pragma mark Convenience constructors

+ (instancetype)valueWithGedcomString:(NSString *)gedcom
{
	return [[self alloc] initWithGedcom:gedcom];
}

+ (instancetype)ageWithSimpleAge:(NSDateComponents *)c qualifier:(GCAgeQualifier)q
{
	return [[self alloc] initWithSimpleAge:c qualifier:q];
}

+ (instancetype)ageWithAgeKeyword:(NSString *)s qualifier:(GCAgeQualifier)q
{
	return [[self alloc] initWithAgeKeyword:s qualifier:q];
}

+ (instancetype)ageWithInvalidAgeString:(NSString *)s
{
	return [[self alloc] initWithInvalidAgeString:s];
}

#pragma mark Helpers

+ (instancetype)ageFromDate:(GCDate *)fromDate toDate:(GCDate *)toDate
{
    NSCalendar *calendar = fromDate.calendar;
    
    NSDateComponents *ageComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit)
                                                  fromDate:fromDate.minDate
                                                    toDate:toDate.minDate
                                                   options:NO];
    
    return [GCAge ageWithSimpleAge:ageComponents qualifier:GCAgeNoQualifier];
}

#pragma mark Comparison

- (NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [self.refAge compare:[other refAge]];
	}
}

#pragma mark NSCopying compliance

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

#pragma mark Objective-C properties

@dynamic refAge;

@dynamic gedcomString;
@dynamic displayString;

- (NSUInteger)years
{
    return [self.refAge.ageComponents year];
}

- (NSUInteger)months
{
    return [self.refAge.ageComponents month];
}

- (NSUInteger)days
{
    return [self.refAge.ageComponents day];
}

@end
