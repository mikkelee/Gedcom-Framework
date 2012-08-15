// 
//  GCDate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

#import "GCDate.h"

#import <ParseKit/ParseKit.h>

#import "GCAge.h"

#pragma mark Private methods

@class GCSimpleDate, GCDatePhrase;

@interface GCDate ()

+ (id)dateWithSimpleDate:(NSDateComponents *)co; //assumes Gregorian
+ (id)dateWithSimpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca;

+ (id)dateWithApproximateDate:(GCSimpleDate *)sd withType:(NSString *)t;
+ (id)dateWithInterpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p;

+ (id)dateWithPeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;
+ (id)dateWithRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;

+ (id)dateWithPhrase:(NSString *)p;

+ (id)dateWithInvalidDateString:(NSString *)s;

@property (retain, readonly) GCSimpleDate *refDate; //used for sorting, etc.

@end

#pragma mark -
#pragma mark Concrete subclasses
#pragma mark -

#pragma mark GCSimpleDate

@interface GCSimpleDate : GCDate

@property NSDateComponents *dateComponents;
@property NSCalendar *calendar;

@end

@implementation GCSimpleDate

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleDate class]]) {
		if (![[self calendar] isEqual:[other calendar]]) {
			NSLog(@"WARNING: It is not safe at this moment to compare two GCDateSimples with different calendars.");
		}
		if ([[self dateComponents] year] != [[other dateComponents] year]) {
			return [[NSNumber numberWithInteger:[[self dateComponents] year]] compare:[NSNumber numberWithInteger:[[other dateComponents] year]]];
		} else if ([[self dateComponents] month] != [[other dateComponents] month]) {
			return [[NSNumber numberWithInteger:[[self dateComponents] month]] compare:[NSNumber numberWithInteger:[[other dateComponents] month]]];
		} else {
			return [[NSNumber numberWithInteger:[[self dateComponents] day]] compare:[NSNumber numberWithInteger:[[other dateComponents] day]]];
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

@synthesize dateComponents;
@synthesize calendar;

@end

#pragma mark GCDatePhrase

@interface GCDatePhrase : GCDate

@property NSString *phrase;
@property (readonly) NSCalendar *calendar;

@end

@implementation GCDatePhrase

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"(%@)", [self phrase]];
}

- (NSString *)displayString
{
    return [self gedcomString];
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

@synthesize phrase;

@end

#pragma mark GCAttributedDate

@interface GCAttributedDate : GCDate

@property GCSimpleDate *simpleDate;
@property (readonly) NSCalendar *calendar;

@end

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

@synthesize simpleDate;

@end

#pragma mark GCApproximateDate

@interface GCApproximateDate : GCAttributedDate

@property NSString *dateType;

@end

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

@synthesize dateType;

@end

#pragma mark GCInterpretedDate

@interface GCInterpretedDate : GCAttributedDate

@property GCDatePhrase *datePhrase;

@end

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

@synthesize datePhrase;

@end

#pragma mark GCDatePair

@class GCSimpleDate;

@interface GCDatePair : GCDate

@property GCSimpleDate *dateA;
@property GCSimpleDate *dateB;
@property (readonly) NSCalendar *calendar;

@end

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

@interface GCDatePeriod : GCDatePair

@end

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

@interface GCDateRange : GCDatePair

@end

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

@interface GCInvalidDate : GCDate

@property NSString *string;
@property (readonly) NSCalendar *calendar;

@end

@implementation GCInvalidDate

- (NSString *)gedcomString
{
	return [self string];
}

- (NSString *)displayString
{
    return [self gedcomString];
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

@synthesize string;

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
#pragma mark Parsing
#pragma mark -

#pragma mark GCAgeAssembler

@interface GCDateAssembler : NSObject {
	NSArray *monthNames;
	NSDateComponents *currentDateComponents;
}

- (void)initialize;

@property GCDate *date;

@end

@implementation GCDateAssembler

- (GCDateAssembler *)init
{	
    if (![super init])
        return nil;
    
    monthNames = [@"JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" componentsSeparatedByString:@" "];
    [self initialize];
    
    return self;
}

- (void)initialize
{
    [self setDate:nil];
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchYear:(PKAssembly *)a
{
    [currentDateComponents setYear:[[[a pop] stringValue] intValue]];
}


- (void)didMatchMonthNumeral:(PKAssembly *)a
{
    [currentDateComponents setMonth:[[[a pop] stringValue] intValue]];
}


- (void)didMatchMonthWord:(PKAssembly *)a
{
    [currentDateComponents setMonth:[monthNames indexOfObject:[[a pop] stringValue]]+1];
}


- (void)didMatchDay:(PKAssembly *)a
{
    [currentDateComponents setDay:[[[a pop] stringValue] intValue]];
}


- (void)didMatchYearGreg:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDateGreg:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate dateWithSimpleDate:currentDateComponents]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchDateJuln:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate dateWithSimpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:nil]]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchMonthHebr:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDateHebr:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate dateWithSimpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar]]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchMonthFren:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDateFren:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate dateWithSimpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:nil]]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchDateSimple:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDatePhraseContents:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDatePeriod:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
    id aDate = [a pop];
    id keyword = [a pop];
    if ([[keyword stringValue] isEqualToString:@"TO"]) {
        if ([a isStackEmpty]) {
            [a push:[GCDate dateWithPeriodFrom:nil to:aDate]];
        } else {
            id anotherDate = [a pop];
            id keyword = [a pop];
            if ([[keyword stringValue] isEqualToString:@"FROM"]) {
                [a push:[GCDate dateWithPeriodFrom:anotherDate to:aDate]];
            }
        }
    } else if ([[keyword stringValue] isEqualToString:@"FROM"]) {
        [a push:[GCDate dateWithPeriodFrom:aDate to:nil]];
    }
}


- (void)didMatchDateRange:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id aDate = [a pop];
    id keyword = [a pop];
    if ([a isStackEmpty]) {
        if ([[keyword stringValue] isEqualToString:@"BEF"]) {
            [a push:[GCDate dateWithRangeFrom:nil to:aDate]];
        } else if ([[keyword stringValue] isEqualToString:@"AFT"]) {
            [a push:[GCDate dateWithRangeFrom:aDate to:nil]];
        }
    } else {
        if ([[keyword stringValue] isEqualToString:@"AND"]) {
            id anotherDate = [a pop];
            id keyword = [a pop];
            if ([[keyword stringValue] isEqualToString:@"BET"]) {
                [a push:[GCDate dateWithRangeFrom:anotherDate to:aDate]];
            }
        }
    }
}


- (void)didMatchDateApproximated:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id simpleDate = [a pop];
    id type = [a pop];
    [a push:[GCDate dateWithApproximateDate:simpleDate withType:[type stringValue]]];
}


- (void)didMatchDateInterpreted:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id phrase = [a pop];
    id simpleDate = [a pop];
    id keyword = [a pop];
    if ([[keyword stringValue] isEqualToString:@"INT"]) {
        [a push:[GCDate dateWithInterpretedDate:simpleDate withPhrase:phrase]];		
    } else {
        NSLog(@"This shouldn't happen (keyword wasn't INT): %@", keyword);
    }
}


- (void)didMatchDatePhrase:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id endParen = [a pop];
    
    if ([[endParen stringValue] isEqualToString:@")"]) {
        id contents;
        
        NSString *phrase = [[a pop] stringValue];
        
        while ( (contents = [[a pop] stringValue]) ) {
            if ([contents isEqualToString:@"("]) {
                break;
            }
            phrase = [NSString stringWithFormat:@"%@ %@", contents, phrase];
        }
        
        [a push:[GCDate dateWithPhrase:phrase]];
    } else {
        NSLog(@"This shouldn't happen (endParen wasn't ')'): %@", endParen);
    }
}


- (void)didMatchDate:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
    if ([[a stack] count] == 1) {
        DebugLog(@"Stack was empty, setting date");
        [self setDate:[a pop]];
    } else {
        DebugLog(@"ERROR: Objects remaining on stack!");
        DebugLog(@"stack: %@", [a stack]);
    }
}

@synthesize date;

@end

#pragma mark GCDateParser

@interface GCDateParser : NSObject {
	NSMutableDictionary *cache;
	
	PKParser *dateParser;
	GCDateAssembler *assembler;
	NSLock *lock;
}

+ (GCDateParser *)sharedDateParser;
- (GCDate *)parseGedcom:(NSString *)g;


@end

@implementation GCDateParser

+ (id)sharedDateParser // fancy new ARC/GCD singleton!
{
    static dispatch_once_t predDateParser = 0;
    __strong static id _sharedGCDateParser = nil;
    dispatch_once(&predDateParser, ^{
        _sharedGCDateParser = [[self alloc] init];
    });
    return _sharedGCDateParser;
}

- (GCDateParser *)init
{
    if (![super init])
        return nil;
    
    cache = [NSMutableDictionary dictionary];
    
    NSString *grammarPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"gedcom.date" ofType:@"grammar"];
    
    NSString *grammar = [NSString stringWithContentsOfFile:grammarPath encoding:NSUTF8StringEncoding error:nil];
    
    assembler = [[GCDateAssembler alloc] init];
    //NSLog(@"Began creating dateParser.");
    dateParser = [[PKParserFactory factory] parserFromGrammar:grammar assembler:assembler];
    //NSLog(@"Finished creating dateParser.");
    
    lock = [NSLock new];
    
    return self;
}

- (GCDate *)parseGedcom:(NSString *)g
{
    if (cache[g]) {
        //NSLog(@"Getting cached date for %@", g);
        return [cache[g] copy];
    }
    
    [lock lock];
    [assembler initialize];
    
    [dateParser parse:[NSString stringWithFormat:@"[%@]", g]]; //wrapping in brackets (see grammar)
    
    GCDate *date = [assembler date];
    
    if (date == nil) {
        date = [GCDate dateWithInvalidDateString:g];
    }
    cache[g] = date;
    
    [lock unlock];
    
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

@synthesize minDate;
@synthesize maxDate;

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
