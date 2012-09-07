//
//  GCDateParser.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDate_internal.h"
#import <ParseKit/ParseKit.h>

#pragma mark GCAgeAssembler

@interface GCDateAssembler : NSObject

- (void)initialize;

@property GCDate *date;

@end

@implementation GCDateAssembler {
	NSArray *monthNames;
	NSDateComponents *currentDateComponents;
}

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

@end

#pragma mark GCDateParser

@implementation GCDateParser {
	NSMutableDictionary *cache;
	
	PKParser *dateParser;
	GCDateAssembler *assembler;
	NSLock *lock;
}

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

