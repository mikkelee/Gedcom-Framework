//
//  GCObjectTests.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCObjectTests : SenTestCase 
@end

@implementation GCObjectTests

- (void)testObjectValues
{
    GCAttribute *date = [GCAttribute attributeWithType:@"Date" dateValue:[GCDate dateWithGedcom:@"1 JAN 1901"]];
    
    STAssertEqualObjects([date stringValue], @"1 JAN 1901", nil);
}

- (void)testSimpleObjects
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual record" inContext:ctx];
    
    NSArray *names = [NSArray arrayWithObjects:
                      [GCValue valueWithString:@"Jens /Hansen/"], 
                      [GCValue valueWithString:@"Jens /Hansen/ Smed"], 
                      nil];
    
    [indi setValue:names 
            forKey:@"Name"];
	
    //alternately:
	// [indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    // [indi addAttributeWithType:@"Name" value:[GCValue valueWithString:@"Jens /Hansen/"]];
    
	GCAttribute *birt = [GCAttribute attributeWithType:@"Birth"];
    
	[birt addAttributeWithType:@"Date" dateValue:[GCDate dateWithGedcom:@"1 JAN 1901"]];
    
    [[indi properties] addObject:birt];
    
    //alternately:
    // [indi addProperty:birt];
    // [[indi valueForKey:[birt type]] addObject:birt];
    
    [indi addAttributeWithType:@"Death" boolValue:YES];
    
    [indi setValue:[NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00"] forKey:@"lastModified"]; //Setting a known date so output is known
    
    STAssertEqualObjects([indi gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 Jan 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
    ctx = [GCContext context]; //fresh context
	
    GCNode *node = [[GCNode alloc] initWithTag:@"INDI" 
                                         value:nil
                                          xref:@"@INDI1@"
                                      subNodes:[NSArray arrayWithObjects:
                                                [GCNode nodeWithTag:@"NAME" 
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:@"NAME" 
                                                              value:@"Jens /Hansen/"],
                                                [[GCNode alloc] initWithTag:@"BIRT" 
                                                                      value:nil
                                                                       xref:nil
                                                                   subNodes:[NSArray arrayWithObjects:
                                                                             [GCNode nodeWithTag:@"DATE"
                                                                                           value:@"1 JAN 1901"],
                                                                              nil]
                                                                             ],
                                                [GCNode nodeWithTag:@"DEAT" 
                                                              value:@"Y"],
                                                 nil]];
    
    GCEntity *object = [GCEntity entityWithGedcomNode:node inContext:ctx];
    
    STAssertEqualObjects([object gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y"
                         , nil);
}

- (void)testRelationships
{
	GCContext *ctx = [GCContext context];
	
	GCEntity *husb = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	[husb addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	[husb addAttributeWithType:@"Sex" genderValue:GCMale];
	
	GCEntity *wife = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	[wife addAttributeWithType:@"Name" stringValue:@"Anne /Larsdatter/"];
	[wife addAttributeWithType:@"Sex" genderValue:GCFemale];
	
	GCEntity *chil = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	[chil addAttributeWithType:@"Name" stringValue:@"Hans /Jensen/"];
	[chil addAttributeWithType:@"Sex" genderValue:GCMale];
	
    GCEntity *fam = [GCEntity entityWithType:@"Family record" inContext:ctx];
    
    [fam setValue:husb forKey:@"Husband"];
    [fam setValue:wife forKey:@"Wife"];
    [fam setValue:[NSArray arrayWithObject:chil] forKey:@"Child"];
    
    //alternately:
	// [fam addRelationshipWithType:@"Husband" target:husb];
	// [fam addRelationshipWithType:@"Wife" target:wife];
	// [fam addRelationshipWithType:@"Child" target:chil];
	
    //Setting known dates
    NSDate *knownDate = [NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00"];
    [fam setValue:knownDate forKey:@"lastModified"];
    [husb setValue:knownDate forKey:@"lastModified"];
    [wife setValue:knownDate forKey:@"lastModified"];
    [chil setValue:knownDate forKey:@"lastModified"];

    STAssertEqualObjects([fam gedcomString], 
                         @"0 @FAM1@ FAM\n"
                         @"1 HUSB @INDI1@\n"
                         @"1 WIFE @INDI2@\n"
                         @"1 CHIL @INDI3@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 Jan 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects([husb gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
						 @"1 FAMS @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 Jan 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects([wife gedcomString], 
                         @"0 @INDI2@ INDI\n"
                         @"1 NAME Anne /Larsdatter/\n"
						 @"1 SEX F\n"
						 @"1 FAMS @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 Jan 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects([chil gedcomString], 
                         @"0 @INDI3@ INDI\n"
                         @"1 NAME Hans /Jensen/\n"
						 @"1 SEX M\n"
						 @"1 FAMC @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 Jan 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
}

- (void)testSetGedcomString
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual record" inContext:ctx];
    
    [indi setGedcomString:@"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y"];
    
    GCAttribute *birt1 = [[indi valueForKey:@"Birth"] lastObject];
    GCAttribute *deat1 = [[indi valueForKey:@"Death"] lastObject];
    
    //NSLog(@"[indi properties]: %@", [indi properties]);
    
    [indi setGedcomString:@"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT\n"
                         @"2 DATE 1 JAN 1930"];
    
    GCAttribute *birt2 = [[indi valueForKey:@"Birth"] lastObject];
    GCAttribute *deat2 = [[indi valueForKey:@"Death"] lastObject];
    
    STAssertTrue([birt1 isEqualTo:birt2], nil);
    STAssertFalse([deat1 isEqual:deat2], nil);
    
    //NSLog(@"[indi properties]: %@", [indi properties]);
    
    STAssertEquals([[indi properties] count], (NSUInteger)4, nil);
}

- (void)testCoding
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
	
	GCFile *file = [GCFile fileWithGedcomNodes:nodes];
    
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:file];
    
    GCFile *decodedFile = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
    
    //NSLog(@"file: %@", [file gedcomString]);
    //NSLog(@"decodedFile: %@", [decodedFile gedcomString]);
    
    STAssertTrue([file isEqualTo:decodedFile], nil);
}

- (void)testFileValidation
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
	
	GCFile *file = [GCFile fileWithGedcomNodes:nodes];
    
    NSError *error = nil;
    
    BOOL result = [file validateFile:&error];
    
    STAssertTrue(result, nil);
    STAssertNil(error, nil);
}

- (void)testObjectValidation
{
    GCContext *ctx = [GCContext context];
    
    // Submitter that's missing a required property NAME.
    NSArray *malformedNodes = [GCNode arrayOfNodesFromString:
                               @"0 @SUBM1@ SUBM\n"
                               @"1 LANG English\n"
                               @"1 LANG English\n"
                               @"1 LANG English\n"
                               @"1 LANG English"
                               ];
    
    GCEntity *submitter = [GCEntity entityWithGedcomNode:[malformedNodes lastObject] inContext:ctx];
    
    NSError *error = nil;
    
    BOOL result = [submitter validateObject:&error];
    
    STAssertFalse(result, nil);
    STAssertEqualObjects([[error userInfo] valueForKey:NSLocalizedDescriptionKey], @"Too few values for key Name", nil);
}

- (void)testFile
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
    NSMutableArray *gc_inputLines = [NSMutableArray array];
    
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [gc_inputLines addObject:line];
    }];

	NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
	
	GCFile *file = [GCFile fileWithGedcomNodes:nodes];
	
	NSMutableArray *gc_outputLines = [NSMutableArray arrayWithCapacity:3];
	for (GCNode *node in [file gedcomNodes]) {
		[gc_outputLines addObjectsFromArray:[node gedcomLines]];
	}
	
	//NSLog(@"file: %@", [gc_outputLines componentsJoinedByString:@"\n"]);
	
	for (int i = 0; i < [gc_outputLines count]; i++) {
		//NSLog(@"test: %@ - %@", [gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i]);
		STAssertEqualObjects([gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i], nil);
	}
}

- (void)AtestFile2
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"allged" ofType:@"ged"];
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *gc_inputLines = [NSMutableArray array];
    
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [gc_inputLines addObject:line];
    }];

	NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
	
	GCFile *file = [GCFile fileWithGedcomNodes:nodes];
	
	NSMutableArray *gc_outputLines = [NSMutableArray arrayWithCapacity:3];
	for (GCNode *node in [file gedcomNodes]) {
		[gc_outputLines addObjectsFromArray:[node gedcomLines]];
	}
	
	//NSLog(@"file: %@", [gc_outputLines componentsJoinedByString:@"\n"]);
	
	for (int i = 0; i < [gc_outputLines count]; i++) {
		STAssertEqualObjects([gc_inputLines objectAtIndex:i], [gc_outputLines objectAtIndex:i], nil);
	}
}

@end
