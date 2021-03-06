//
//  GCDate_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

#pragma mark Private methods

@class GCSimpleDate, GCDatePhrase;

@interface GCDate ()

+ (instancetype)dateWithSimpleDate:(NSDateComponents *)co calendar:(NSCalendar *)ca;

+ (instancetype)dateWithApproximateDate:(GCSimpleDate *)sd type:(NSString *)t;
+ (instancetype)dateWithInterpretedDate:(GCSimpleDate *)sd phrase:(GCDatePhrase *)p;

+ (instancetype)dateWithPeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;
+ (instancetype)dateWithRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;

+ (instancetype)dateWithPhrase:(NSString *)p;

+ (instancetype)dateWithInvalidDateString:(NSString *)s;

@end

#pragma mark GCSimpleDate

@interface GCSimpleDate : GCDate

@property NSDateComponents *dateComponents;
@property NSCalendar *calendar;
@property NSString *yearGregSuffix;

@end

#pragma mark GCDatePhrase

@interface GCDatePhrase : GCDate

@property NSString *phrase;
@property (readonly) NSCalendar *calendar;

@end

#pragma mark GCAttributedDate

@interface GCAttributedDate : GCDate

@property GCSimpleDate *simpleDate;
@property (readonly) NSCalendar *calendar;

@end

#pragma mark GCApproximateDate

@interface GCApproximateDate : GCAttributedDate

@property NSString *dateType;

@end

#pragma mark GCInterpretedDate

@interface GCInterpretedDate : GCAttributedDate

@property GCDatePhrase *datePhrase;

@end

#pragma mark GCDatePair

@class GCSimpleDate;

@interface GCDatePair : GCDate

@property GCSimpleDate *dateA;
@property GCSimpleDate *dateB;
@property (readonly) NSCalendar *calendar;

@end

#pragma mark GCDatePeriod

@interface GCDatePeriod : GCDatePair

@end

#pragma mark GCDateRange

@interface GCDateRange : GCDatePair

@end

#pragma mark GCInvalidDate

@interface GCInvalidDate : GCDate

@property NSString *string;
@property (readonly) NSCalendar *calendar;

@end

#pragma mark GCDateParser

@interface GCDateParser : NSObject

+ (GCDateParser *)sharedDateParser;
- (GCDate *)parseGedcom:(NSString *)g;

@end
