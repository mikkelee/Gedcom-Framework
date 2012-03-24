//
//  DateParser.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 16/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDateParser.h"
#import "GCDateAssembler.h"
#import "GCDate.h"
#import "GCInvalidDate.h"

@implementation GCDateParser

+ (id)sharedDateParser // fancy new ARC/GCD singleton!
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedGCDateParser = nil;
    dispatch_once(&pred, ^{
        _sharedGCDateParser = [[self alloc] init];
    });
    return _sharedGCDateParser;
}

- (GCDateParser *)init
{
	if (![super init])
		return nil;
	
    cache = [NSMutableDictionary dictionaryWithCapacity:3];
    
	NSString *grammarPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"gedcom.date" ofType:@"grammar"];
	
	NSString *grammar = [NSString stringWithContentsOfFile:grammarPath encoding:NSUTF8StringEncoding error:nil];
	
	assembler = [[GCDateAssembler alloc] init];
	//NSLog(@"Began creating dateParser.");
	dateParser = [[PKParserFactory factory] parserFromGrammar:grammar assembler:assembler];
	//NSLog(@"Finished creating dateParser.");
	
	lock = [NSLock new];
	
	return self;
}

- (GCDate *)parseGedcom:(NSString *)g
{
	if ([cache objectForKey:g]) {
        //NSLog(@"Getting cached date for %@", g);
		return [[cache objectForKey:g] copy];
	}
	
	[lock lock];
	[assembler initialize];
	
	[dateParser parse:[NSString stringWithFormat:@"[%@]", g]]; //wrapping in brackets (see grammar)
	
	GCDate *date = [assembler date];
	
	if (date == nil) {
		date = [GCDate invalidDateString:g];
	}
	[cache setObject:date forKey:g];
	
	[lock unlock];
	
	return date;
}

@end
