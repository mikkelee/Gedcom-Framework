//
//  GCDateFormatter.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 14/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDateFormatter.h"
#import "GCDate.h"

@implementation GCDateFormatter

- (NSString *)editingStringForObjectValue:(id)date
{
	return [self stringForObjectValue:date];
}

- (NSString *)stringForObjectValue:(id)date;
{
    if (![date isKindOfClass:[GCDate class]]) {
		NSLog(@"date was wrong class: %@", [date className]);
        return nil;
    }
	
	return [date gedcomString]; //TODO '<' instead of 'BEF' etc?
}
/*
- (NSAttributedString *)attributedStringForObjectValue:(id)date withDefaultAttributes:(NSDictionary *)attributes
{
	return [[NSAttributedString alloc] initWithString:[self editingStringForObjectValue:date]]; //TODO
}
*/
- (BOOL)getObjectValue:(id *)outVal forString:(NSString *)string errorDescription:(NSString **)error
{
	BOOL result = NO;
	//NSLog(@"string: %@", string);
	
	GCDate *date = [GCDate dateFromGedcom:string];
	//NSLog(@"date: %@", date);
	
	if (date) {
		result = YES;
	}
	
	if (outVal) {
		*outVal = date;
	}
	
	return result; 
}

- (BOOL)getObjectValue:(out id *)outVal forString:(NSString *)string range:(inout NSRange *)rangep error:(out NSError **)error
{
	BOOL result = NO;
	//NSLog(@"string: %@", string);
	
	GCDate *date = [GCDate dateFromGedcom:string];
	//NSLog(@"date: %@", date);
	
	if (date) {
		result = YES;
	}
	
	if (outVal) {
		*outVal = date;
	}
	
	return result; 
}

@end
