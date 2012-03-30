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

+ (id)dateFromGedcom:(NSString *)gedcom;

- (NSComparisonResult)compare:(id)other;

//subclasses implement these:

@property (retain, readonly) NSString *gedcomString;
@property (retain, readonly) NSString *displayString;
@property (retain, readonly) NSString *description;

@property (readonly) NSUInteger year;
@property (readonly) NSUInteger month;
@property (readonly) NSUInteger day;

@end


@interface GCDate ()

//convenience factory methods:

+ (id)simpleDate:(NSDateComponents *)co; //assumes Gregorian
+ (id)simpleDate:(NSDateComponents *)co withCalendar:(NSCalendar *)ca;

+ (id)approximateDate:(GCSimpleDate *)sd withType:(NSString *)t;
+ (id)interpretedDate:(GCSimpleDate *)sd withPhrase:(GCDatePhrase *)p;

+ (id)datePeriodFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;
+ (id)dateRangeFrom:(GCSimpleDate *)f to:(GCSimpleDate *)t;

+ (id)datePhrase:(NSString *)p;

+ (id)invalidDateString:(NSString *)s;

@property (retain, readonly) GCSimpleDate *refDate; //used for sorting, etc.

@end


