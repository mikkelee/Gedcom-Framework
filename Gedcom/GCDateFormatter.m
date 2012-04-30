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

- (NSString *)editingStringForObjectValue:(id)anObject
{
    NSParameterAssert([anObject isKindOfClass:[GCDate class]]);

	return [anObject gedcomString];
}

- (NSString *)stringForObjectValue:(id)anObject;
{
    NSParameterAssert([anObject isKindOfClass:[GCDate class]]);
    
	return [anObject displayString];
}

- (BOOL)getObjectValue:(id *)outVal forString:(NSString *)string errorDescription:(NSString **)error
{
	BOOL result = NO;
	//NSLog(@"string: %@", string);
	
	GCDate *date = [GCDate valueWithGedcomString:string];
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
	
	GCDate *date = [GCDate valueWithGedcomString:string];
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
