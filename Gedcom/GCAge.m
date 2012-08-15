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
    GCAgeNoQualifier,
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

@property (readonly) GCSimpleAge *refAge; //used for sorting, etc.

@end

#pragma mark -
#pragma mark Concrete subclasses
#pragma mark -

#pragma mark GCSimpleAge

@interface GCSimpleAge : GCAge

@property NSDateComponents *ageComponents;

@end

@implementation GCSimpleAge

- (NSString *)gedcomString
{
    NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:3];
	
	if ([[self ageComponents] year] >= 1) {
        [stringComponents addObject:[NSString stringWithFormat:@"%ldy", [[self ageComponents] year]]];
    }
    
	if ([[self ageComponents] month] >= 1) {
		[stringComponents addObject:[NSString stringWithFormat:@"%ldm", [[self ageComponents] month]]];
	}
	
	if ([[self ageComponents] day] >= 1) {
		[stringComponents addObject:[NSString stringWithFormat:@"%ldd", [[self ageComponents] day]]];
	}
    
    if ([stringComponents count] == 0) {
        [stringComponents addObject:@"0y"];
    }
    
    return [stringComponents componentsJoinedByString:@" "];
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:3];
	
	if ([[self ageComponents] year] == 1) {
		[stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d year" value:@"%d year" table:@"Values"], [[self ageComponents] year]]];
	} else if ([[self ageComponents] year] > 1) {
		[stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d years" value:@"%d years" table:@"Values"], [[self ageComponents] year]]];
	}
    
	if ([[self ageComponents] month] == 1) {
		[stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d month" value:@"%d month" table:@"Values"], [[self ageComponents] month]]];
	} else if ([[self ageComponents] month] > 1) {
		[stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d months" value:@"%d months" table:@"Values"], [[self ageComponents] month]]];
	}
	
	if ([[self ageComponents] day] == 1) {
		[stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d day" value:@"%d day" table:@"Values"], [[self ageComponents] day]]];
	} else if ([[self ageComponents] day] > 1) {
		[stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d days" value:@"%d days" table:@"Values"], [[self ageComponents] day]]];
	}
    
    if ([stringComponents count] == 0) {
        [stringComponents addObject:[NSString stringWithFormat:[frameworkBundle localizedStringForKey:@"%d years" value:@"%d years" table:@"Values"], 0]];
    }
    
    return [stringComponents componentsJoinedByString:@", "];
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
			return [[NSNumber numberWithInteger:[[self ageComponents] year]] compare:[NSNumber numberWithInteger:[[other ageComponents] year]]];
		} else if ([[self ageComponents] month] != [[other ageComponents] month]) {
			return [[NSNumber numberWithInteger:[[self ageComponents] month]] compare:[NSNumber numberWithInteger:[[other ageComponents] month]]];
		} else {
			return [[NSNumber numberWithInteger:[[self ageComponents] day]] compare:[NSNumber numberWithInteger:[[other ageComponents] day]]];
		}
	} else {
		return [self compare:[other refAge]];
	}
}

@synthesize ageComponents;

@end

#pragma mark GCQualifiedAge

@interface GCQualifiedAge : GCAge

@property GCAge * age;
@property GCAgeQualifier qualifier;

@end

@implementation GCQualifiedAge

NSString * const GCAgeQualifier_toString[] = {
    @"< ",
    @"",
    @"> "
};

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@%@", GCAgeQualifier_toString[[self qualifier]], [[self age] gedcomString]];
}

- (NSString *)displayString
{
	return [NSString stringWithFormat:@"%@%@", GCAgeQualifier_toString[[self qualifier]], [[self age] displayString]];
}

- (GCSimpleAge *)refAge
{
	return [[self age] refAge];
}

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [[self age] compare:[other refAge]];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    return [[NSNumber numberWithInt:[self qualifier]] compare:[NSNumber numberWithInt:[other qualifier]]];
}

@synthesize age;
@synthesize qualifier;

@end

#pragma mark GCAgeKeyword

@interface GCAgeKeyword : GCAge

@property (copy) NSString *keyword;

@end

@implementation GCAgeKeyword

- (NSString *)gedcomString
{
	return [self keyword];
}

- (NSString *)displayString
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    return [frameworkBundle localizedStringForKey:[self gedcomString] value:[self gedcomString] table:@"Values"];
}

/*
 CHILD = age < 8 years 
 INFANT = age < 1 year 
 STILLBORN = died just prior, at, or near birth, 0 years 
 */
- (GCSimpleAge *)refAge
{
	GCSimpleAge *age = [[GCSimpleAge alloc] init];
    
    NSDateComponents *ageComponents = [[NSDateComponents alloc] init]; 
    
    GCAgeQualifier qualifier = GCAgeNoQualifier;
    
    if ([[self keyword] isEqualToString:@"CHILD"]) {
        [ageComponents setYear:8];
        qualifier = GCAgeLessThan;
    } else if ([[self keyword] isEqualToString:@"INFANT"]) {
        [ageComponents setYear:1];
        qualifier = GCAgeLessThan;
    } else if ([[self keyword] isEqualToString:@"STILLBORN"]) {
        [ageComponents setYear:0];
    } else {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidAgeKeywordException"
														 reason:[NSString stringWithFormat:@"Invalid AgeKeyword '%@'", [self keyword]]
													   userInfo:nil];
		@throw exception;
    }
    
	[age setAgeComponents:ageComponents];
    
    return [GCAge ageWithAge:age withQualifier:qualifier];
}

@synthesize keyword;

@end

#pragma mark GCInvalidAge

@interface GCInvalidAge : GCAge

@property NSString *string;

@end

@implementation GCInvalidAge

- (NSString *)gedcomString
{
	return [self string];
}

- (NSString *)displayString
{
    return [self gedcomString];
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

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t predAge = 0;
    __strong static id _sharedAgePlaceholder = nil;
    dispatch_once(&predAge, ^{
        _sharedAgePlaceholder = [super allocWithZone:zone];
    });
    return _sharedAgePlaceholder;
}

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

//COV_NF_START
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
//COV_NF_END

#pragma mark Convenience constructors

+ (id)valueWithGedcomString:(NSString *)gedcom
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
                                                  fromDate:[fromDate minDate] 
                                                    toDate:[toDate maxDate] 
                                                   options:NO];
    
    return [GCAge ageWithSimpleAge:ageComponents];
}

#pragma mark Comparison

- (NSComparisonResult) compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [[self refAge] compare:[other refAge]];
	}
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
