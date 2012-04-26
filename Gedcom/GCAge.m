//
//  GCAge.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

#import "GCAge.h"
#import <ParseKit/ParseKit.h>

#import "GCDate.h"

#pragma mark Private methods

@class GCSimpleAge;

typedef enum {
    GCAgeLessThan,
    GCAgeGreaterThan
} GCAgeQualifier;

@interface GCAge ()

- (id)initWithSimpleAge:(NSDateComponents *)c;
- (id)initWithAgeKeyword:(NSString *)s;
- (id)initWithInvalidAgeString:(NSString *)s;
- (id)initWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q;

+ (id)ageWithSimpleAge:(NSDateComponents *)c;
+ (id)ageWithAgeKeyword:(NSString *)p;
+ (id)ageWithInvalidAgeString:(NSString *)s;
+ (id)ageWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q;

@property (retain, readonly) GCSimpleAge *refAge; //used for sorting, etc.

@end

#pragma mark -
#pragma mark Concrete subclasses
#pragma mark -

#pragma mark GCSimpleAge

@interface GCSimpleAge : GCAge

@property (copy) NSDateComponents *ageComponents;

@end

@implementation GCSimpleAge

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCSimpleAge (%d years, %d months, %d days)]", [[self ageComponents] year], [[self ageComponents] month], [[self ageComponents] day]];
}

- (NSString *)gedcomString
{
	NSString *months = @"";
	if ([[self ageComponents] month] >= 1) {
		months = [NSString stringWithFormat:@" %@", [[self ageComponents] month]];
	}
	
	NSString *days = @"";
	if ([[self ageComponents] day] >= 1) {
		days = [NSString stringWithFormat:@" %dd", [[self ageComponents] day]];
	}
	
	return [NSString stringWithFormat:@"%dy%@%@", [[self ageComponents] year], months, days];
}

- (GCSimpleAge *)refAge
{
	return self;
}

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else if ([other isKindOfClass:[GCSimpleAge class]]) {
		if ([[self ageComponents] year] != [[other ageComponents] year]) {
			return [[NSNumber numberWithInt:[[self ageComponents] year]] compare:[NSNumber numberWithInt:[[other ageComponents] year]]];
		} else if ([[self ageComponents] month] != [[other ageComponents] month]) {
			return [[NSNumber numberWithInt:[[self ageComponents] month]] compare:[NSNumber numberWithInt:[[other ageComponents] month]]];
		} else {
			return [[NSNumber numberWithInt:[[self ageComponents] day]] compare:[NSNumber numberWithInt:[[other ageComponents] day]]];
		}
	} else {
		return [self compare:[other refAge]];
	}
}

@synthesize ageComponents;

@end

#pragma mark GCQualifiedAge

@interface GCQualifiedAge : GCAge

@property (copy) GCAge * age;
@property (assign) GCAgeQualifier qualifier;

@end

@implementation GCQualifiedAge

NSString * const GCAgeQualifier_toString[] = {
    @"<",
    @">"
};

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCQualifiedAge %@ %@]", GCAgeQualifier_toString[[self qualifier]], [self age]];
}

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", GCAgeQualifier_toString[[self qualifier]], [self age]];
}

- (GCSimpleAge *)refAge
{
	return [[self age] refAge];
}

@synthesize age;
@synthesize qualifier;

@end

#pragma mark GCAgeKeyword

@interface GCAgeKeyword : GCAge

@property (copy) NSString *keyword;

@end

@implementation GCAgeKeyword

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCAgeKeyword '%@']", [self keyword]];
}

-(NSString *)gedcomString
{
	return [self keyword];
}

/*
 CHILD = age < 8 years 
 INFANT = age < 1 year 
 STILLBORN = died just prior, at, or near birth, 0 years 
 */
- (GCSimpleAge *)refAge
{
	GCSimpleAge *a = [[GCSimpleAge alloc] init];
    
    NSDateComponents *ageComponents = [[NSDateComponents alloc] init]; 
    
    if ([[self keyword] isEqualToString:@"CHILD"]) {
        [ageComponents setYear:8];
    } else if ([[self keyword] isEqualToString:@"INFANT"]) {
        [ageComponents setYear:1];
    } else if ([[self keyword] isEqualToString:@"STILLBORN"]) {
        [ageComponents setYear:0];
    } else {
        //TODO error!!
    }
    
	[a setAgeComponents:ageComponents];
    
	//TODO return a qualifiedage with GCLessThan ?
	
	return a;
}

@synthesize keyword;

@end

#pragma mark GCInvalidAge

@interface GCInvalidAge : GCAge

@property (copy) NSString *string;

@end

@implementation GCInvalidAge

-(NSString *)description
{
	return [NSString stringWithFormat:@"[GCInvalidAge '%@']", [self string]];
}

-(NSString *)gedcomString
{
	return [self string];
}

- (GCSimpleAge *)refAge
{
	GCSimpleAge *m = [[GCSimpleAge alloc] init];
    
	[m setAgeComponents:[[NSDateComponents alloc] init]];
    
    return m;
}

@synthesize string;

@end

#pragma mark -
#pragma mark Placeholder class
#pragma mark -

@interface GCPlaceholderAge : GCAge
@end

@implementation GCPlaceholderAge

- (id)initWithSimpleAge:(NSDateComponents *)c;
{
	id age = [[GCSimpleAge alloc] init];
	
	[age setAgeComponents:c];
	
	return age;
}

- (id)initWithAgeKeyword:(NSString *)s
{
	id age = [[GCAgeKeyword alloc] init];
	
	[age setKeyword:s];
	
	return age;
}

- (id)initWithInvalidAgeString:(NSString *)s
{
	id age = [[GCInvalidAge alloc] init];
	
	[age setString:s];
	
	return age;
}

- (id)initWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
	id age = [[GCQualifiedAge alloc] init];
	
	[age setAge:a];
	[age setQualifier:q];
	
	return age;
}

@end

#pragma mark -
#pragma mark Parsing
#pragma mark -

#pragma mark GCAgeAssembler

@interface GCAgeAssembler : NSObject

- (void)initialize;

@property (copy) GCAge *age;

@end

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
	[a push:[GCAge ageWithSimpleAge:currentAgeComponents]];
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

@synthesize age;

@end

#pragma mark GCAgeParser

@interface GCAgeParser : NSObject

+ (GCAgeParser *)sharedAgeParser;
- (GCAge *)parseGedcom:(NSString *)g;

@end

@implementation GCAgeParser {
	NSMutableDictionary *cache;
	
	PKParser *ageParser;
	GCAgeAssembler *assembler;
	NSLock *lock;
}

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
		age = [GCAge ageWithInvalidAgeString:g];
	}
    
	[cache setObject:age forKey:g];
	
	[lock unlock];
	
	return age;
}

@end

#pragma mark -
#pragma mark Abstract class
#pragma mark -

@implementation GCAge

#pragma mark Initialization

+ (id)allocWithZone:(NSZone *)zone
{
    if ([GCAge self] == self)
        return [GCPlaceholderAge allocWithZone:zone];    
    return [super allocWithZone:zone];
}

- (id)initWithGedcom:(NSString *)gedcom
{
	return [[GCAgeParser sharedAgeParser] parseGedcom:gedcom];
}

- (id)initWithSimpleAge:(NSDateComponents *)c
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithAgeKeyword:(NSString *)s
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithInvalidAgeString:(NSString *)s
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

#pragma mark Convenience constructors

+ (id)ageWithGedcom:(NSString *)gedcom
{
	return [[self alloc] initWithGedcom:gedcom];
}

+ (id)ageWithSimpleAge:(NSDateComponents *)c;
{
	return [[self alloc] initWithSimpleAge:c];
}

+ (id)ageWithAgeKeyword:(NSString *)s
{
	return [[self alloc] initWithAgeKeyword:s];
}

+ (id)ageWithInvalidAgeString:(NSString *)s
{
	return [[self alloc] initWithInvalidAgeString:s];
}

+ (id)ageWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q
{
	return [[self alloc] initWithAge:a withQualifier:q];
}

#pragma mark Helpers

+ (id)ageFromDate:(GCDate *)fromDate toDate:(GCDate *)toDate
{
    NSCalendar *calendar = [[fromDate valueForKey:@"refDate"] calendar];
    
    NSDateComponents *ageComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                  fromDate:[fromDate date] 
                                                    toDate:[toDate date] 
                                                   options:NO];
    
    return [GCAge ageWithSimpleAge:ageComponents];
}

#pragma mark Comparison

-(NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refAge] compare:[other refAge]];
	}
}

#pragma mark NSCoding compliance

- (id)initWithCoder:(NSCoder *)coder
{
	return [self initWithGedcom:[coder decodeObjectForKey:@"gedcomString"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self gedcomString] forKey:@"gedcomString"];
}

#pragma mark NSCopying compliance

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

#pragma mark Objective-C properties

@dynamic refAge;

@dynamic gedcomString;
@dynamic displayString;
@dynamic description;

- (NSUInteger)years
{
    return [[[self refAge] ageComponents] year];
}

- (NSUInteger)months
{
    return [[[self refAge] ageComponents] month];
}

- (NSUInteger)days
{
    return [[[self refAge] ageComponents] day];
}

@end
