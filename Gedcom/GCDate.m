// 
//  GCDate.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDate.h"

#import "GCDateParser.h"

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

@end
