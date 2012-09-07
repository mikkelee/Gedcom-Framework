//
//  GCDate_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDate.h"

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

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

#pragma mark GCSimpleDate

@interface GCSimpleDate : GCDate

@property NSDateComponents *dateComponents;
@property NSCalendar *calendar;

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
