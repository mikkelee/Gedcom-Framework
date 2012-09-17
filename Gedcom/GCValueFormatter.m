//
//  GCValueFormatter.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValueFormatter.h"

#import "GCValue.h"

#import "GCString.h"
#import "GCNumber.h"
#import "GCDate.h"
#import "GCAge.h"
#import "GCBool.h"
#import "GCGender.h"

@interface GCValueFormatter ()

- (Class)classToFormat;

@end

@implementation GCStringFormatter

- (Class)classToFormat
{
    return [GCString class];
}

@end

@implementation GCNumberFormatter

- (Class)classToFormat
{
    return [GCNumber class];
}

@end

@implementation GCDateFormatter

- (Class)classToFormat
{
    return [GCDate class];
}

@end

@implementation GCAgeFormatter

- (Class)classToFormat
{
    return [GCAge class];
}

@end

@implementation GCBoolFormatter

- (Class)classToFormat
{
    return [GCBool class];
}

@end

@implementation GCGenderFormatter

- (Class)classToFormat
{
    return [GCGender class];
}

@end

#pragma mark Actual formatter

@implementation GCValueFormatter 

//COV_NF_START
- (Class)classToFormat
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
//COV_NF_END

- (NSString *)editingStringForObjectValue:(id)anObject
{
	if (![anObject isKindOfClass:[self classToFormat]]) {
        //NSLog(@"%@ -- %@ is not kind of %@ (editingStringForObjectValue)", anObject, [anObject className], NSStringFromClass([self classToFormat]));
        return [anObject description];
    }
    
	return [anObject gedcomString];
}

- (NSString *)stringForObjectValue:(id)anObject;
{
	if (![anObject isKindOfClass:[self classToFormat]]) {
        //NSLog(@"%@ -- %@ is not kind of %@ (stringForObjectValue)", anObject, [anObject className], NSStringFromClass([self classToFormat]));
        return [anObject description];
    }
    
    return [anObject displayString];
}

- (BOOL)getObjectValue:(id *)outVal forString:(NSString *)string errorDescription:(NSString **)error
{
	BOOL result = NO;
	//NSLog(@"string: %@", string);
	
	id obj = [[self classToFormat] valueWithGedcomString:string];
	//NSLog(@"obj: %@", obj);
	
	if (obj) {
		result = YES;
	}
	
	if (outVal) {
		*outVal = obj;
	}
	
	return result; 
}

@end
