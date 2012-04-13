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

#import "GCSimpleDate.h"
#import "GCApproximateDate.h"
#import "GCInterpretedDate.h"
#import "GCDatePeriod.h"
#import "GCDateRange.h"
#import "GCDatePhrase.h"
#import "GCInvalidDate.h"

/*
 DATE_VALUE: = {Size=1:35} 
 [ 
 <DATE> | 
 <DATE_PERIOD> | 
 <DATE_RANGE> 
 <DATE_APPROXIMATED> | 
 INT <DATE> (<DATE_PHRASE>) | 
 (<DATE_PHRASE>) 
 ] 
 
 The DATE_VALUE represents the date of an activity, attribute, or event where: 
 INT =Interpreted from knowledge about the associated date phrase included in parentheses. 
 
 An acceptable alternative to the date phrase choice is to use one of the other choices
 such as <DATE_APPROXIMATED> choice as the DATE line value and then include the <DATE_PHRASE>
 as a NOTE value subordinate to the DATE line. 
 
 The date value can take on the date form of just a date, an approximated date, between a date
 and another date, and from one date to another date. The preferred form of showing date
 imprecision, is to show, for example, MAY 1890 rather than ABT 12 MAY 1890. This is because
 limits have not been assigned to the precision of the prefixes such as ABT or EST. 
 
 */

#pragma mark Private methods

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

#pragma mark TODO

#pragma mark -
#pragma mark Placeholder class
#pragma mark -

@interface GCPlaceholderDate : GCDate
@end

@implementation GCPlaceholderDate

- (id)initWithSimpleDate:(NSDateComponents *)co
{
	id date = [[GCSimpleDate alloc] init];
	
	[date setDateComponents:co];
	[date setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
	
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
	[date setPhrase:p];
	
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

@property (copy) GCDate *date;

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
    static dispatch_once_t pred = 0;
    __strong static id _sharedGCDateParser = nil;
    dispatch_once(&pred, ^{
        _sharedGCDateParser = [[self alloc] init];
    });
    return _sharedGCDateParser;
}

- (GCDateParser *)init
{
    if (![super init])
        return nil;
    
    cache = [NSMutableDictionary dictionaryWithCapacity:3];
    
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
    if ([cache objectForKey:g]) {
        //NSLog(@"Getting cached date for %@", g);
        return [[cache objectForKey:g] copy];
    }
    
    [lock lock];
    [assembler initialize];
    
    [dateParser parse:[NSString stringWithFormat:@"[%@]", g]]; //wrapping in brackets (see grammar)
    
    GCDate *date = [assembler date];
    
    if (date == nil) {
        date = [GCDate dateWithInvalidDateString:g];
    }
    [cache setObject:date forKey:g];
    
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

#pragma mark Convenience constructors

+ (id)dateWithGedcom:(NSString *)gedcom
{
	return [[self alloc] initWithGedcom:gedcom];
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

#pragma mark Comparison

-(NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refDate] compare:[other refDate]];
	}
}

#pragma mark NSCoding compliance

- (id)initWithCoder:(NSCoder *)coder
{
	return [self initWithGedcom:[coder decodeObjectForKey:@"gedcomString"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self gedcomString] forKey:@"gedcomString"];
}

#pragma mark NSCopying compliance

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

#pragma mark Properties

@dynamic refDate;

@dynamic gedcomString;
@dynamic displayString;
@dynamic description;

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
