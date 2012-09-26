// 
//  GCDate.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDate.h"
#import "GCDate_internal.h"

#import "GCAge.h"

#pragma mark -
#pragma mark Concrete subclasses
#pragma mark -

#pragma mark GCSimpleDate

@implementation GCSimpleDate {
    NSCalendar *_calendar;
}

- (NSString *)gedcomString
{
    NSString *calendarString = @"";
    NSArray *monthNames = nil;
    
    if ([[self.calendar calendarIdentifier] isEqualToString:NSGregorianCalendar]) {
        monthNames = @[ @"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC" ];
    } else if ([[self.calendar calendarIdentifier] isEqualToString:NSHebrewCalendar]) {
        monthNames = @[ @"TSH", @"CSH", @"KSL", @"TVT", @"SHV", @"ADR", @"ADS", @"NSN", @"IYR", @"SVN", @"TMZ", @"AAV", @"ELL" ];
        calendarString = @"@#DHEBREW@ ";
    } else if ([[self.calendar calendarIdentifier] isEqualToString:nil]) { //TODO
        monthNames = @[ @"VEND", @"BRUM", @"FRIM", @"NIVO", @"PLUV", @"VENT", @"GERM", @"FLOR", @"PRAI", @"MESS", @"THER", @"FRUC", @"COMP" ];
        calendarString = @"@#DFRENCH R@ ";
    }
    
    NSParameterAssert(monthNames);
	
	NSString *month = @"";
	if ([self.dateComponents month] >= 1 && [self.dateComponents month] <= 12) {
		month = [NSString stringWithFormat:@"%@ ", monthNames[[self.dateComponents month]-1]];
	}
	
	NSString *day = @"";
	if ([self.dateComponents day] >= 1 && [self.dateComponents day] <= 31) {
		day = [NSString stringWithFormat:@"%ld ", [self.dateComponents day]];
	}
	
	return [NSString stringWithFormat:@"%@%@%@%04ld", calendarString, day, month, [self.dateComponents year]];
}

- (NSString *)displayString
{
    if ([self.dateComponents day] < 1 || [self.dateComponents day] > 31) {
        if ([self.dateComponents month] < 1 || [self.dateComponents month] > 12) {
            return [NSString stringWithFormat:@"%ld", [self.dateComponents year]];
        }
    }
    
    return [NSDateFormatter localizedStringFromDate:[self.calendar dateFromComponents:self.dateComponents]
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSCalendar *)calendar
{
    return _calendar;
}

- (void)setCalendar:(NSCalendar *)calendar
{
    _calendar = calendar;
}

- (NSDate *)minDate
{
    NSDateComponents *tmpComponents = [self.dateComponents copy];
    
    //NSLog(@"minDate: %@", tmpComponents);
    if ([tmpComponents day] <= 0) { [tmpComponents setDay:1]; }
    if ([tmpComponents month] <= 0) { [tmpComponents setMonth:1]; }
    [tmpComponents setHour:00];
    [tmpComponents setMinute:00];
    [tmpComponents setSecond:01];
    //NSLog(@"minDate: %@", tmpComponents);
    
    return [self.calendar dateFromComponents:tmpComponents];
}

- (NSDate *)maxDate
{
    NSDateComponents *tmpComponents = [self.dateComponents copy];
    
    //NSLog(@"maxDate: %@", tmpComponents);
    if ([tmpComponents day] <= 0) { [tmpComponents setDay:31]; }
    if ([tmpComponents month] <= 0) { [tmpComponents setMonth:12]; }
    [tmpComponents setHour:23];
    [tmpComponents setMinute:59];
    [tmpComponents setSecond:59];
    //NSLog(@"maxDate: %@", tmpComponents);
    
    return [self.calendar dateFromComponents:tmpComponents];
}

@end

#pragma mark GCDatePhrase

@implementation GCDatePhrase

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"(%@)", self.phrase];
}

- (NSString *)displayString
{
    return self.gedcomString;
}

- (NSCalendar *)calendar
{
	return nil;
}

- (NSDate *)minDate
{
    return [NSDate distantPast];
}

- (NSDate *)maxDate
{
    return [NSDate distantPast];
}

@end

#pragma mark GCAttributedDate

@implementation GCAttributedDate

- (NSCalendar *)calendar
{
	return self.simpleDate.calendar;
}

- (NSDate *)minDate
{
    return self.simpleDate.minDate;
}

- (NSDate *)maxDate
{
    return self.simpleDate.maxDate;
}

@end

#pragma mark GCApproximateDate

@implementation GCApproximateDate

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", self.dateType, self.simpleDate.gedcomString];
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *key = [NSString stringWithFormat:@"%@ %%@", self.dateType];
    
	return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:key value:@"~ %@" table:@"Values"], self.simpleDate.displayString];
}

@end

#pragma mark GCInterpretedDate

@implementation GCInterpretedDate

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"INT %@ %@", self.simpleDate.gedcomString, self.datePhrase.gedcomString];
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
	return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"INT %@ %@" value:@"\"%@\" %@" table:@"Values"], self.simpleDate.displayString, self.datePhrase.displayString];
}

@end

#pragma mark GCDatePair

@implementation GCDatePair {
    GCSimpleDate *_dateA;
    GCSimpleDate *_dateB;
}

- (NSCalendar *)calendar
{
	if (self.dateA) {
		return self.dateA.calendar;
	} else {
		return self.dateB.calendar;
	}
}

- (GCSimpleDate *)dateA
{
    return _dateA;
}

- (void)setDateA:(GCSimpleDate *)dateA
{
    NSParameterAssert(dateA == nil || _dateB == nil || [dateA.calendar isEqual:_dateB.calendar]);
    
    _dateA = dateA;
}

- (GCSimpleDate *)dateB
{
    return _dateB;
}

- (void)setDateB:(GCSimpleDate *)dateB
{
    NSParameterAssert(dateB == nil || _dateA == nil || [_dateA.calendar isEqual:dateB.calendar]);
    
    _dateB = dateB;
}

- (NSDate *)minDate
{
    if (self.dateA) {
        return self.dateA.maxDate;
    } else {
        return nil;
    }
}

- (NSDate *)maxDate
{
    if (self.dateB) {
        return self.dateB.minDate;
    } else {
        return nil;
    }
}

@end

#pragma mark GCDatePeriod

@implementation GCDatePeriod

- (NSString *)gedcomString
{
	if (self.dateA == nil) {
		return [NSString stringWithFormat:@"TO %@", self.dateB.gedcomString];
	} else if (self.dateB == nil) {
		return [NSString stringWithFormat:@"FROM %@", self.dateA.gedcomString];
	} else {
		return [NSString stringWithFormat:@"FROM %@ TO %@", self.dateA.gedcomString, self.dateB.gedcomString];
	}
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (self.dateA == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"TO %@" value:@"… %@" table:@"Values"], self.dateB.displayString];
	} else if (self.dateB == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"FROM %@" value:@"%@ …" table:@"Values"], self.dateA.displayString];
	} else {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"FROM %@ TO %@" value:@"%@ … %@" table:@"Values"], self.dateA.displayString, self.dateB.displayString];
	}
}

@end

#pragma mark GCDateRange

@implementation GCDateRange

- (NSString *)gedcomString
{
	if (self.dateA == nil) {
		return [NSString stringWithFormat:@"BEF %@", self.dateB.gedcomString];
	} else if (self.dateB == nil) {
		return [NSString stringWithFormat:@"AFT %@", self.dateA.gedcomString];
	} else {
		return [NSString stringWithFormat:@"BET %@ AND %@", self.dateA.gedcomString, self.dateB.gedcomString];
	}
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (self.dateA == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"BEF %@" value:@"< %@" table:@"Values"], self.dateB.displayString];
	} else if (self.dateB == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"AFT %@" value:@"> %@" table:@"Values"], self.dateA.displayString];
	} else {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"BET %@ AND %@" value:@"%@ – %@" table:@"Values"], self.dateA.displayString, self.dateB.displayString];
	}
}

@end

#pragma mark GCInvalidDate

@implementation GCInvalidDate

- (NSString *)gedcomString
{
	return self.string;
}

- (NSString *)displayString
{
    return self.gedcomString;
}

- (NSCalendar *)calendar
{
	return nil;
}

- (NSDate *)minDate
{
    return nil;
}

- (NSDate *)maxDate
{
    return nil;
}

@end

#pragma mark -
#pragma mark Placeholder class
#pragma mark -

@interface GCPlaceholderDate : GCDate
@end

@implementation GCPlaceholderDate

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t predDate = 0;
    __strong static id _sharedDatePlaceholder = nil;
    dispatch_once(&predDate, ^{
        _sharedDatePlaceholder = [super allocWithZone:zone];
    });
    return _sharedDatePlaceholder;
}

- (id)initWithSimpleDate:(NSDateComponents *)co calendar:(NSCalendar *)ca
{
	GCSimpleDate *date = [[GCSimpleDate alloc] init];
	
	date.dateComponents = co;
    date.calendar = ca;
	
	return (id)date;
}

- (id)initWithApproximateDate:(GCSimpleDate *)sd type:(NSString *)t
{
	GCApproximateDate *date = [[GCApproximateDate alloc] init];
	
    date.simpleDate = sd;
    date.dateType = t;
	
	return (id)date;
}

- (id)initWithInterpretedDate:(GCSimpleDate *)sd phrase:(GCDatePhrase *)p
{
	GCInterpretedDate *date = [[GCInterpretedDate alloc] init];
	
    date.simpleDate = sd;
    date.datePhrase = p;
	
	return (id)date;
}

- (id)initWithDatePeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
	GCDatePeriod *date = [[GCDatePeriod alloc] init];
	
    date.dateA = f;
    date.dateB = t;
	
	return (id)date;
}

- (id)initWithDateRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
	GCDateRange *date = [[GCDateRange alloc] init];
	
    date.dateA = f;
    date.dateB = t;
	
	return (id)date;
}

- (id)initWithDatePhrase:(NSString *)p
{
	GCDatePhrase *date = [[GCDatePhrase alloc] init];
	
	date.phrase = p;
	
	return (id)date;
}

- (id)initWithInvalidDateString:(NSString *)s
{
	GCInvalidDate *date = [[GCInvalidDate alloc] init];
	
    date.string = s;
	
	return (id)date;
}

@end

#pragma mark -
#pragma mark Abstract class
#pragma mark -

@implementation GCDate 

#pragma mark Initialization

+ (id)allocWithZone:(NSZone *)zone
{
    if ([GCDate self] == self)
        return [GCPlaceholderDate allocWithZone:zone];    
    return [super allocWithZone:zone];
}

- (id)initWithGedcom:(NSString *)gedcom
{
	return [[GCDateParser sharedDateParser] parseGedcom:gedcom];
}

- (id)initWithDate:(NSDate *)date
{
    NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [calendar setTimeZone:utc];
    
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                  fromDate:date];
    
    return [GCDate dateWithSimpleDate:dateComponents calendar:calendar];
}

//COV_NF_START
- (id)initWithSimpleDate:(NSDateComponents *)co calendar:(NSCalendar *)ca
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithApproximateDate:(GCSimpleDate *)sd type:(NSString *)t
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithInterpretedDate:(GCSimpleDate *)sd phrase:(GCDatePhrase *)p
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithDatePeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithDateRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithDatePhrase:(NSString *)p
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithInvalidDateString:(NSString *)s
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}
//COV_NF_END

#pragma mark Convenience constructors

+ (id)valueWithGedcomString:(NSString *)gedcom
{
	return [[self alloc] initWithGedcom:gedcom];
}

+ (id)dateWithDate:(NSDate *)date
{
    return [[self alloc] initWithDate:date];
}

+ (id)dateWithSimpleDate:(NSDateComponents *)co calendar:(NSCalendar *)ca
{
	return [[self alloc] initWithSimpleDate:co calendar:ca];
}

+ (id)dateWithApproximateDate:(GCSimpleDate *)sd type:(NSString *)t
{
	return [[self alloc] initWithApproximateDate:sd type:t];
}

+ (id)dateWithInterpretedDate:(GCSimpleDate *)sd phrase:(GCDatePhrase *)p
{
    return [[self alloc] initWithInterpretedDate:sd phrase:p];
}

+ (id)dateWithPeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
    return [[self alloc] initWithDatePeriodFrom:f to:t];
}

+ (id)dateWithRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
    return [[self alloc] initWithDateRangeFrom:f to:t];
}

+ (id)dateWithPhrase:(NSString *)p
{
    return [[self alloc] initWithDatePhrase:p];
}

+ (id)dateWithInvalidDateString:(NSString *)s
{
    return [[self alloc] initWithInvalidDateString:s];
}

#pragma mark Helpers

- (id)dateByAddingAge:(GCAge *)age
{
    NSDate *theDate = self.minDate ? self.minDate : self.maxDate;
    
    NSDateComponents *ageComponents = [[NSDateComponents alloc] init];
    
    NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    [ageComponents setYear:age.years];
    [ageComponents setMonth:age.months];
    [ageComponents setDay:age.days];
    [ageComponents setHour:0];
    [ageComponents setTimeZone:utc];
    
    NSDate *result = [self.calendar dateByAddingComponents:ageComponents toDate:theDate options:0];
    
    return [GCDate dateWithDate:result];
}

- (BOOL)containsDate:(NSDate *)date
{
    if (self.minDate == nil) {
        return ([self.maxDate compare:date] == NSOrderedAscending);
    } else if (self.maxDate == nil) {
        return ([self.minDate compare:date] == NSOrderedDescending);
    } else {
        return ([self.minDate compare:date] == NSOrderedDescending) && ([self.maxDate compare:date] == NSOrderedAscending);
    }
}


#pragma mark Comparison

- (BOOL)isLessThan:(GCDate *)other
{
    if (!self.minDate) {
        if (!other.minDate) {
            return [self.maxDate compare:other.maxDate] == NSOrderedAscending;
        } else {
            return [self.maxDate compare:other.minDate] != NSOrderedDescending;
        }
    } else if (!self.maxDate) {
        if (!other.minDate) {
            return [self.minDate compare:other.maxDate] == NSOrderedAscending;
        } else if (!other.maxDate) {
            return [self.minDate compare:other.minDate] == NSOrderedAscending;
        } else {
            return [self.minDate compare:other.minDate] != NSOrderedDescending
                && [self.minDate compare:other.maxDate] == NSOrderedAscending;
        }
    } else {
        if (!other.minDate || !other.maxDate) {
            return ![other isLessThan:self]; // reverse comparison
        } else if ([self.minDate compare:other.minDate] == NSOrderedSame) {
            return [self.maxDate compare:other.maxDate] == NSOrderedAscending;
        } else {
            return [self.minDate compare:other.minDate] == NSOrderedAscending;
        }
    }
}

- (BOOL)isEqualTo:(GCDate *)other
{
    return self.minDate && other.minDate && [self.minDate compare:other.minDate] == NSOrderedSame
        && self.maxDate && other.maxDate && [self.maxDate compare:other.maxDate] == NSOrderedSame;
}

- (NSComparisonResult) compare:(GCDate *)other {
    if (![other isKindOfClass:[GCDate class]]) {
        return NSOrderedAscending;
    }
    
    if ([self isLessThan:other]) {
        return NSOrderedAscending;
    } else if ([self isEqualTo:other]) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

#pragma mark @selector trickery
/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSLog(@"GCDate respondsToSelector: %@", NSStringFromSelector(aSelector));
    
    return [super respondsToSelector:aSelector];
}
*/
#pragma mark NSCopying compliance

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

#pragma mark Objective-C properties

@dynamic gedcomString;
@dynamic displayString;

@end
