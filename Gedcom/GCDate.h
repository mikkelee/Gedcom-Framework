//
//  GCDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCSimpleDate;
@class GCApproximateDate;
@class GCInterpretedDate;
@class GCDatePeriod;
@class GCDateRange;
@class GCDatePhrase;
@class GCInvalidDate;

@interface GCDate : NSObject {
	
}

//generally you should use this:

+ (GCDate *)dateFromGedcom:(NSString *)gedcom;

//convenience factory methods:

+ (GCSimpleDate *)simpleDate:(NSDateComponents *)co; //assumes Gregorian
+ (GCSimpleDate *)simpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca;

+ (GCApproximateDate *)approximateDate:(GCSimpleDate *)sd withType:(NSString *)t;
+ (GCInterpretedDate *)interpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p;

+ (GCDatePeriod *)datePeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;
+ (GCDateRange *)dateRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;

+ (GCDatePhrase *)datePhrase:(NSString *)p;

+ (GCInvalidDate *)invalidDateString:(NSString *)s;

- (NSComparisonResult)compare:(id)other;

//subclasses implement these:

@property (retain, readonly) GCSimpleDate *refDate; //used for sorting, etc.

@property (retain, readonly) NSString *gedcomString;
@property (retain, readonly) NSString *displayString;
@property (retain, readonly) NSString *description;

@end



