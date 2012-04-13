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
    [a push:[GCDate simpleDate:currentDateComponents]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchDateJuln:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate simpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:nil]]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchMonthHebr:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDateHebr:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate simpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar]]];
    
    currentDateComponents = [[NSDateComponents alloc] init];
}


- (void)didMatchMonthFren:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    
}


- (void)didMatchDateFren:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a push:[GCDate simpleDate:currentDateComponents withCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:nil]]];
    
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
            [a push:[GCDate datePeriodFrom:nil to:aDate]];
        } else {
            id anotherDate = [a pop];
            id keyword = [a pop];
            if ([[keyword stringValue] isEqualToString:@"FROM"]) {
                [a push:[GCDate datePeriodFrom:anotherDate to:aDate]];
            }
        }
    } else if ([[keyword stringValue] isEqualToString:@"FROM"]) {
        [a push:[GCDate datePeriodFrom:aDate to:nil]];
    }
}


- (void)didMatchDateRange:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id aDate = [a pop];
    id keyword = [a pop];
    if ([a isStackEmpty]) {
        if ([[keyword stringValue] isEqualToString:@"BEF"]) {
            [a push:[GCDate dateRangeFrom:nil to:aDate]];
        } else if ([[keyword stringValue] isEqualToString:@"AFT"]) {
            [a push:[GCDate dateRangeFrom:aDate to:nil]];
        }
    } else {
        if ([[keyword stringValue] isEqualToString:@"AND"]) {
            id anotherDate = [a pop];
            id keyword = [a pop];
            if ([[keyword stringValue] isEqualToString:@"BET"]) {
                [a push:[GCDate dateRangeFrom:anotherDate to:aDate]];
            }
        }
    }
}


- (void)didMatchDateApproximated:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id simpleDate = [a pop];
    id type = [a pop];
    [a push:[GCDate approximateDate:simpleDate withType:[type stringValue]]];
}


- (void)didMatchDateInterpreted:(PKAssembly *)a
{
    DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    id phrase = [a pop];
    id simpleDate = [a pop];
    id keyword = [a pop];
    if ([[keyword stringValue] isEqualToString:@"INT"]) {
        [a push:[GCDate interpretedDate:simpleDate withPhrase:phrase]];		
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
        
        [a push:[GCDate datePhrase:phrase]];
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
        date = [GCDate invalidDateString:g];
    }
    [cache setObject:date forKey:g];
    
    [lock unlock];
    
    return date;
}

@end

#pragma mark -

@implementation GCDate 

+ (GCDate *)dateFromGedcom:(NSString *)gedcom
{
	return [[GCDateParser sharedDateParser] parseGedcom:gedcom];
}

+ (GCSimpleDate *)simpleDate:(NSDateComponents *)co
{
	GCSimpleDate *date = [[GCSimpleDate alloc] init];
	
	[date setDateComponents:co];
	[date setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
	
	return date;
}

+ (GCSimpleDate *)simpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca
{
	GCSimpleDate *date = [[GCSimpleDate alloc] init];
	
	[date setDateComponents:co];
	[date setCalendar:ca];
	
	return date;
}

+ (GCApproximateDate *)approximateDate:(GCSimpleDate *)sd withType:(NSString *)t
{
	GCApproximateDate *date = [[GCApproximateDate alloc] init];
	
	[date setSimpleDate:sd];
	[date setType:t];
	
	return date;
}

+ (GCInterpretedDate *)interpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p
{
	GCInterpretedDate *date = [[GCInterpretedDate alloc] init];
	
	[date setSimpleDate:sd];
	[date setPhrase:p];
	
	return date;
}

+ (GCDatePeriod *)datePeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
	GCDatePeriod *date = [[GCDatePeriod alloc] init];
	
	[date setDateA:f];
	[date setDateB:t];
	
	return date;
}

+ (GCDateRange *)dateRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t
{
	GCDateRange *date = [[GCDateRange alloc] init];
	
	[date setDateA:f];
	[date setDateB:t];
	
	return date;
}

+ (GCDatePhrase *)datePhrase:(NSString *)p
{
	GCDatePhrase *date = [[GCDatePhrase alloc] init];
	
	[date setPhrase:p];
	
	return date;
}

+ (GCInvalidDate *)invalidDateString:(NSString *)s
{
	GCInvalidDate *date = [[GCInvalidDate alloc] init];
	
	[date setString:s];
	
	return date;
}

-(NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refDate] compare:[other refDate]];
	}
}

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
