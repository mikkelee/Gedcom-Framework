//
//  GCAgeAssembler.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 21/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <ParseKit/ParseKit.h>
#import "GCAgeAssembler.h"
#import "GCAge.h"
#import "GCSimpleAge.h"
#import "GCAgeKeyword.h"

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

@implementation GCAgeAssembler

- (GCAgeAssembler *)init
{	
	if (![super init])
		return nil;
	
	[self initialize];
	
	return self;
}

- (void)initialize
{
	[self setAge:nil];
	currentAgeComponents = [[NSDateComponents alloc] init];
	[currentAgeComponents setDay:0];
	[currentAgeComponents setMonth:0];
	[currentAgeComponents setYear:0];
}

- (void)didMatchDays:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a pop]; // 'd'
	[currentAgeComponents setDay:[[[a pop] stringValue] intValue]];
}

- (void)didMatchMonths:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a pop]; // 'm'
	[currentAgeComponents setMonth:[[[a pop] stringValue] intValue]];
}

- (void)didMatchYears:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
    [a pop]; // 'y'
	[currentAgeComponents setYear:[[[a pop] stringValue] intValue]];
}

- (void)didMatchAgeKeyword:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	[a push:[GCAge ageKeyword:[[a pop] stringValue]]];
}

- (void)didMatchSimpleAge:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	[a push:[GCAge simpleAge:currentAgeComponents]];
}

- (void)didMatchQualifiedAge:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id anAge = [a pop];
	id qualifier = [a pop];
	if ([a isStackEmpty]) {
		if ([[qualifier stringValue] isEqualToString:@"<"]) {
			[a push:[GCAge age:anAge withQualifier:GCAgeLessThan]];
		} else if ([[qualifier stringValue] isEqualToString:@">"]) {
			[a push:[GCAge age:anAge withQualifier:GCAgeGreaterThan]];
		}
	} else {
		DebugLog(@"ERROR: Objects remaining on stack!");
		DebugLog(@"stack: %@", [a stack]);
	}
}

- (void)didMatchAge:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	if ([[a stack] count] == 1) {
		DebugLog(@"Stack was empty, setting date");
		[self setAge:[a pop]];
	} else {
		DebugLog(@"ERROR: Objects remaining on stack!");
		DebugLog(@"stack: %@", [a stack]);
	}
}

@synthesize age;

@end
