//
//  GCAgeParser.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 20/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAgeParser.h"
#import "GCAgeAssembler.h"
#import "GCAge.h"
#import "GCInvalidAge.h"

@implementation GCAgeParser

+ (id)sharedAgeParser // fancy new ARC/GCD singleton!
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedAgeParser = nil;
    dispatch_once(&pred, ^{
        _sharedAgeParser = [[self alloc] init];
    });
    return _sharedAgeParser;
}

- (GCAgeParser *)init
{
	if (![super init])
		return nil;
	
    cache = [NSMutableDictionary dictionaryWithCapacity:3];
    
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
	if ([cache objectForKey:g]) {
        //NSLog(@"Getting cached age for %@", g);
		return [[cache objectForKey:g] copy];
	}
	
	[lock lock];
	[assembler initialize];
	
	[ageParser parse:[NSString stringWithFormat:@"[%@]", g]]; //wrapping in brackets (see grammar)
	
	GCAge *age = [assembler age];
	if (age == nil) {
		age = [GCAge invalidAgeString:g];
	}
    
	[cache setObject:age forKey:g];
	
	[lock unlock];
	
	return age;
}

@end
