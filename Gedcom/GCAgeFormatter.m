//
//  GCAgeFormatter.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCAgeFormatter.h"
#import "GCAge.h"

@implementation GCAgeFormatter

- (NSString *)editingStringForObjectValue:(id)anObject
{
    if (![anObject isKindOfClass:[GCAge class]]) {
        return nil;
    }
	
	return [self stringForObjectValue:anObject];
}

- (NSString *)stringForObjectValue:(id)anObject;
{
    if (![anObject isKindOfClass:[GCAge class]]) {
        return nil;
    }
	
	return [anObject gedcomString];
}

- (BOOL)getObjectValue:(id *)outVal forString:(NSString *)string errorDescription:(NSString **)error
{
	BOOL result = NO;
	
	GCAge *age = [GCAge ageWithGedcom:string];
	
	if (age) {
		result = YES;
	}
	
	if (outVal) {
		*outVal = age;
	}
	
	return result; 
}

- (BOOL)getObjectValue:(out id *)outVal forString:(NSString *)string range:(inout NSRange *)rangep error:(out NSError **)error
{
	BOOL result = NO;
	
	GCAge *age = [GCAge ageWithGedcom:string];
	
	if (age) {
		result = YES;
	}
	
	if (outVal) {
		*outVal = age;
	}
	
	return result; 
}

@end
