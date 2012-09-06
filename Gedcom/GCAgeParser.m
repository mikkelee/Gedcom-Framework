//
//  GCAgeParser.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAgeParser.h"
#import "GCAge_internal.h"
#import <ParseKit/ParseKit.h>

#pragma mark GCAgeAssembler

@implementation GCAgeAssembler {
	NSDateComponents *currentAgeComponents;
}

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
	[a push:[GCAge ageWithAgeKeyword:[[a pop] stringValue]]];
}

- (void)didMatchSimpleAge:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id anAge = [GCAge ageWithSimpleAge:currentAgeComponents];
    [a push:[GCAge ageWithAge:anAge withQualifier:GCAgeNoQualifier]];
}

- (void)didMatchQualifiedAge:(PKAssembly *)a
{
	DebugLog(@"%s (line %d) stack: %@", __FUNCTION__, __LINE__, [a stack]);
	id anAge = [a pop];
	id qualifier = [a pop];
	if ([a isStackEmpty]) {
		if ([[qualifier stringValue] isEqualToString:@"<"]) {
			[a push:[GCAge ageWithAge:anAge withQualifier:GCAgeLessThan]];
		} else if ([[qualifier stringValue] isEqualToString:@">"]) {
			[a push:[GCAge ageWithAge:anAge withQualifier:GCAgeGreaterThan]];
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

@end

#pragma mark GCAgeParser

@implementation GCAgeParser {
	NSMutableDictionary *cache;
	
	PKParser *ageParser;
	GCAgeAssembler *assembler;
	NSLock *lock;
}

+ (id)sharedAgeParser // fancy new ARC/GCD singleton!
{
    static dispatch_once_t predAgeParser = 0;
    __strong static id _sharedAgeParser = nil;
    dispatch_once(&predAgeParser, ^{
        _sharedAgeParser = [[self alloc] init];
    });
    return _sharedAgeParser;
}

- (GCAgeParser *)init
{
	if (![super init])
		return nil;
	
    cache = [NSMutableDictionary dictionary];
    
	NSString *grammarPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"gedcom.age" ofType:@"grammar"];
	
	NSString *grammar = [NSString stringWithContentsOfFile:grammarPath encoding:NSUTF8StringEncoding error:nil];
	
	assembler = [[GCAgeAssembler alloc] init];
	//NSLog(@"Began creating ageParser.");
	ageParser = [[PKParserFactory factory] parserFromGrammar:grammar assembler:assembler];
	//NSLog(@"Finished creating ageParser.");
	
	lock = [NSLock new];
	
	return self;
}

- (GCAge *)parseGedcom:(NSString *)g
{
	if (cache[g]) {
        //NSLog(@"Getting cached age for %@", g);
		return [cache[g] copy];
	}
	
	[lock lock];
	[assembler initialize];
	
	[ageParser parse:[NSString stringWithFormat:@"[%@]", g]]; //wrapping in brackets (see grammar)
	
	GCAge *age = [assembler age];
	if (age == nil) {
		age = [GCAge ageWithInvalidAgeString:g];
	}
    
	cache[g] = age;
	
	[lock unlock];
	
	return age;
}

@end

