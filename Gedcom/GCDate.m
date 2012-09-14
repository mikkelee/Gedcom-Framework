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

@implementation GCSimpleDate

- (NSComparisonResult)compare:(id)other {
    //TODO properly compare BEF/AFT etc!
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleDate class]]) {
		if (![[self calendar] isEqual:[other calendar]]) {
			NSLog(@"WARNING: It is not safe at this moment to compare two GCDateSimples with different calendars.");
		}
		if ([[self dateComponents] year] != [[other dateComponents] year]) {
			return [@([[self dateComponents] year]) compare:@([[other dateComponents] year])];
		} else if ([[self dateComponents] month] != [[other dateComponents] month]) {
			return [@([[self dateComponents] month]) compare:@([[other dateComponents] month])];
		} else {
			return [@([[self dateComponents] day]) compare:@([[other dateComponents] day])];
		}
	} else {
		return [self compare:[other refDate]];
	}
}

- (NSString *)gedcomString
{
	NSArray *monthNames = [@"JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" componentsSeparatedByString:@" "];
	
	NSString *month = @"";
	if ([[self dateComponents] month] >= 1 && [[self dateComponents] month] <= 12) {
		month = [NSString stringWithFormat:@"%@ ", monthNames[[[self dateComponents] month]-1]];
	}
	
	NSString *day = @"";
	if ([[self dateComponents] day] >= 1 && [[self dateComponents] day] <= 31) {
		day = [NSString stringWithFormat:@"%ld ", [[self dateComponents] day]];
	}
	
	return [NSString stringWithFormat:@"%@%@%04ld", day, month, [[self dateComponents] year]];
}

- (NSString *)displayString
{
    if ([[self dateComponents] day] < 1 || [[self dateComponents] day] > 31) {
        if ([[self dateComponents] month] < 1 || [[self dateComponents] month] > 12) {
            return [NSString stringWithFormat:@"%ld", [[self dateComponents] year]];
        }
    }
    
    return [NSDateFormatter localizedStringFromDate:[[self calendar] dateFromComponents:[self dateComponents]]
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSDate *)minDate
{
    return [[self calendar] dateFromComponents:[self dateComponents]];
}

- (NSDate *)maxDate
{
    return [[self calendar] dateFromComponents:[self dateComponents]];
}

- (GCSimpleDate *)refDate
{
	return self;
}

@end

#pragma mark GCDatePhrase

@implementation GCDatePhrase

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"(%@)", [self phrase]];
}

- (NSString *)displayString
{
    return self.gedcomString;
}

- (NSCalendar *)calendar
{
	return nil;
}

- (GCSimpleDate *)refDate
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

#pragma mark GCAttributedDate

@implementation GCAttributedDate

- (NSCalendar *)calendar
{
	return [[self simpleDate] calendar];
}

- (GCSimpleDate *)refDate
{
	return [self simpleDate];
}

- (NSDate *)minDate
{
    return [[[self simpleDate] calendar] dateFromComponents:[[self simpleDate] dateComponents]];
}

- (NSDate *)maxDate
{
    return [[[self simpleDate] calendar] dateFromComponents:[[self simpleDate] dateComponents]];
}

@end

#pragma mark GCApproximateDate

@implementation GCApproximateDate

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", [self dateType], [[self simpleDate] gedcomString]];
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *key = [NSString stringWithFormat:@"%@ %%@", [self dateType]];
    
	return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:key value:@"~ %@" table:@"Values"], [[self simpleDate] displayString]];
}

@end

#pragma mark GCInterpretedDate

@implementation GCInterpretedDate

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"INT %@ %@", [[self simpleDate] gedcomString], [[self datePhrase] gedcomString]];
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
	return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"INT %@ %@" value:@"\"%@\" %@" table:@"Values"], [[self simpleDate] displayString], [[self datePhrase] displayString]];
}

@end

#pragma mark GCDatePair

@implementation GCDatePair {
    GCSimpleDate *_dateA;
    GCSimpleDate *_dateB;
}

- (GCSimpleDate *)refDate
{
	if ([self dateA] == nil) {
		return [self dateB];
	} else if ([self dateB] == nil) {
		return [self dateA];
	} else {
		GCSimpleDate *m = [[GCSimpleDate alloc] init];
		
		[m setCalendar:[[self dateA] calendar]];
		[m setDateComponents:[[[self dateA] calendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[self minDate] dateByAddingTimeInterval:[[self maxDate] timeIntervalSinceDate:[self minDate]]/2]]];
        
		return m;
	}
}

- (NSCalendar *)calendar
{
	if ([self dateA]) {
		return [[self dateA] calendar];
	} else {
		return [[self dateB] calendar];
	}
}

- (GCSimpleDate *)dateA
{
    return _dateA;
}

- (void)setDateA:(GCSimpleDate *)dateA
{
    NSParameterAssert(dateA == nil || _dateB == nil || [[dateA calendar] isEqual:[_dateB calendar]]);
    
    _dateA = dateA;
}

- (GCSimpleDate *)dateB
{
    return _dateB;
}

- (void)setDateB:(GCSimpleDate *)dateB
{
    NSParameterAssert(dateB == nil || _dateA == nil || [[_dateA calendar] isEqual:[dateB calendar]]);
    
    _dateB = dateB;
}

- (NSDate *)minDate
{
    return [[[self dateA] calendar] dateFromComponents:[[self dateA] dateComponents]];
}

- (NSDate *)maxDate
{
    return [[[self dateB] calendar] dateFromComponents:[[self dateB] dateComponents]];
}

@end

#pragma mark GCDatePeriod

@implementation GCDatePeriod

- (NSString *)gedcomString
{
	if ([self dateA] == nil) {
		return [NSString stringWithFormat:@"TO %@", [[self dateB] gedcomString]];
	} else if ([self dateB] == nil) {
		return [NSString stringWithFormat:@"FROM %@", [[self dateA] gedcomString]];
	} else {
		return [NSString stringWithFormat:@"FROM %@ TO %@", [[self dateA] gedcomString], [[self dateB] gedcomString]];
	}
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if ([self dateA] == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"TO %@" value:@"… %@" table:@"Values"], [[self dateB] displayString]];
	} else if ([self dateB] == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"FROM %@" value:@"%@ …" table:@"Values"], [[self dateA] displayString]];
	} else {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"FROM %@ TO %@" value:@"%@ … %@" table:@"Values"], [[self dateA] displayString], [[self dateB] displayString]];
	}
}

@end

#pragma mark GCDateRange

@implementation GCDateRange

- (NSString *)gedcomString
{
	if ([self dateA] == nil) {
		return [NSString stringWithFormat:@"BEF %@", [[self dateB] gedcomString]];
	} else if ([self dateB] == nil) {
		return [NSString stringWithFormat:@"AFT %@", [[self dateA] gedcomString]];
	} else {
		return [NSString stringWithFormat:@"BET %@ AND %@", [[self dateA] gedcomString], [[self dateB] gedcomString]];
	}
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if ([self dateA] == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"BEF %@" value:@"< %@" table:@"Values"], [[self dateB] displayString]];
	} else if ([self dateB] == nil) {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"AFT %@" value:@"> %@" table:@"Values"], [[self dateA] displayString]];
	} else {
        return [NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"BET %@ AND %@" value:@"%@ – %@" table:@"Values"], [[self dateA] displayString], [[self dateB] displayString]];
	}
}

@end

#pragma mark GCInvalidDate

@implementation GCInvalidDate

- (NSString *)gedcomString
{
	return [self string];
}

- (NSString *)displayString
{
    return self.gedcomString;
}

- (GCSimpleDate *)refDate
{
	return nil;
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

static NSCalendar *_gregorianCalendar = nil;

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t predDate = 0;
    __strong static id _sharedDatePlaceholder = nil;
    dispatch_once(&predDate, ^{
        _sharedDatePlaceholder = [super allocWithZone:zone];
        _gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });
    return _sharedDatePlaceholder;
}

- (id)initWithSimpleDate:(NSDateComponents *)co
{
	id date = [[GCSimpleDate alloc] init];
	
	[date setDateComponents:co];
	[date setCalendar:_gregorianCalendar];
	
	return date;
}

- (id)initWithSimpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca
{
	id date = [[GCSimpleDate alloc] init];
	
	[date setDateComponents:co];
	[date setCalendar:ca];
	
	return date;
}

- (id)initWithApproximateDate:(GCSimpleDate *)sd withType:(NSString *)t
{
	id date = [[GCApproximateDate alloc] init];
	
	[date setSimpleDate:sd];
	[date setDateType:t];
	
	return date;
}

- (id)initWithInterpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p
{
	id date = [[GCInterpretedDate alloc] init];
	
	[date setSimpleDate:sd];
	[date setDatePhrase:p];
	
	return date;
}

- (id)initWithDatePeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
	id date = [[GCDatePeriod alloc] init];
	
	[date setDateA:f];
	[date setDateB:t];
	
	return date;
}

- (id)initWithDateRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
	id date = [[GCDateRange alloc] init];
	
	[date setDateA:f];
	[date setDateB:t];
	
	return date;
}

- (id)initWithDatePhrase:(NSString *)p
{
	id date = [[GCDatePhrase alloc] init];
	
	[date setPhrase:p];
	
	return date;
}

- (id)initWithInvalidDateString:(NSString *)s
{
	id date = [[GCInvalidDate alloc] init];
	
	[date setString:s];
	
	return date;
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
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                  fromDate:date];
    
    return [GCDate dateWithSimpleDate:dateComponents withCalendar:calendar];
}

//COV_NF_START
- (id)initWithSimpleDate:(NSDateComponents *)co
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithSimpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithApproximateDate:(GCSimpleDate *)sd withType:(NSString *)t
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithInterpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p
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

+ (id)dateWithSimpleDate:(NSDateComponents *)co
{
	return [[self alloc] initWithSimpleDate:co];
}

+ (id)dateWithSimpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca
{
	return [[self alloc] initWithSimpleDate:co withCalendar:ca];
}

+ (id)dateWithApproximateDate:(GCSimpleDate *)sd withType:(NSString *)t
{
	return [[self alloc] initWithApproximateDate:sd withType:t];
}

+ (id)dateWithInterpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p
{
    return [[self alloc] initWithInterpretedDate:sd withPhrase:p];
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
    NSDate *theDate = [self maxDate] ? [self maxDate] : [self minDate];
    
    NSDateComponents *ageComponents = [[NSDateComponents alloc] init];
    
    [ageComponents setYear:[age years]];
    [ageComponents setMonth:[age months]];
    [ageComponents setDay:[age days]];
    
    return [GCDate dateWithDate:[[[self refDate] calendar] dateByAddingComponents:ageComponents toDate:theDate options:0]];
}

- (BOOL)containsDate:(NSDate *)date
{
    if ([self minDate] == nil) {
        return ([[self maxDate] compare:date] == NSOrderedAscending);
    } else if ([self maxDate] == nil) {
        return ([[self minDate] compare:date] == NSOrderedDescending);
    } else {
        return ([[self minDate] compare:date] == NSOrderedDescending) && ([[self maxDate] compare:date] == NSOrderedAscending);
    }
}


#pragma mark Comparison

- (NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refDate] compare:[other refDate]];
	}
}

#pragma mark NSCopying compliance

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

#pragma mark Objective-C properties

@dynamic refDate;

@dynamic gedcomString;
@dynamic displayString;

- (NSUInteger)year
{
    return [[[self refDate] dateComponents] year];
}

- (NSUInteger)month
{
    return [[[self refDate] dateComponents] month];
}

- (NSUInteger)day
{
    return [[[self refDate] dateComponents] day];
}

@end
