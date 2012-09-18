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

- (void)testAttributeValues
{
    GCAttribute *date = [GCAttribute attributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    
    STAssertEqualObjects([[date value] gedcomString], @"1 JAN 1901", nil);
    
    GCAttribute *name = [GCAttribute attributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"]];
    
    STAssertEqualObjects([[name value] displayString], @"Hansen, Jens (Smed)", nil);
}

- (void)testSimpleObjects
{
    // Create a context
	GCContext *ctx = [GCContext context];
	
    // Create an individual entity in the context
    GCIndividualEntity *indi = [GCIndividualEntity individualInContext:ctx];
    
    // Create an array of names and set them on the individual for the property key "personalNames".
    // When an object receives GCValues for a property key, it will implicitly create attributes.
    // Likewise with GCEntities, creating relationships.
    NSArray *names = @[
        [GCNamestring valueWithGedcomString:@"Jens /Hansen/"], 
        [GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"], 
    ];
    
    [indi setValue:names 
            forKey:@"personalNames"];
	
    // Create a birth attribute, give it a date attribute and add it to the individual
	GCBirthAttribute *birt = [GCBirthAttribute birth];
    
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    
    [[indi mutableArrayValueForKey:@"properties"] addObject:birt];
    
    // You can also use subscripted access, in this case adding a single death attribute
    // with the value yes, indicating that the individual died.
    indi[@"deaths"] = @[[GCBool yes]];
    
    [indi setValue:[NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00 +0000"] forKey:@"lastModified"]; //Setting a known date so output is known
    
    STAssertEqualObjects([indi gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 NAME Jens /Hansen/ Smed\n"
                         @"1 BIRT\n"
                         @"2 DATE 1 JAN 1901\n"
                         @"1 DEAT Y\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
    //NSLog(@"indi individualEvents: %@", [indi individualEvents]);
    
    ctx = [GCContext context]; //fresh context
	
    GCNode *node = [[GCNode alloc] initWithTag:@"INDI" 
                                         value:nil
                                          xref:@"@INDI1@"
                                      subNodes:@[
                                                [GCNode nodeWithTag:@"NAME"
                                                              value:@"Jens /Hansen/"],
                                                [GCNode nodeWithTag:@"NAME"
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:@"BIRT"
                                                              value:nil
                                                           subNodes:@[ [GCNode nodeWithTag:@"DATE"
                                                                                     value:@"1 JAN 1901"] ]],
                                                [GCNode nodeWithTag:@"DEAT" 
                                                              value:@"Y"],
                                                ]];
    
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
	
	GCEntity *husb = [GCEntity entityWithType:@"individual" inContext:ctx];
	[husb addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[husb addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
	GCEntity *wife = [GCEntity entityWithType:@"individual" inContext:ctx];
	[wife addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Anne /Larsdatter/"]];
	[wife addAttributeWithType:@"sex" value:[GCGender femaleGender]];
	
	GCEntity *chil = [GCEntity entityWithType:@"individual" inContext:ctx];
	[chil addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Hans /Jensen/"]];
	[chil addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
    GCEntity *fam = [GCEntity entityWithType:@"family" inContext:ctx];
    
    [fam setValue:husb forKey:@"husband"];
    [fam setValue:wife forKey:@"wife"];
    [fam setValue:[NSArray arrayWithObject:chil] forKey:@"children"];
    
    //alternately:
	// [fam addRelationshipWithType:@"husband" target:husb];
	// [fam addRelationshipWithType:@"wife" target:wife];
	// [fam addRelationshipWithType:@"child" target:chil];
	
    //Setting known dates
    NSDate *knownDate = [NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00 +0000"];
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
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects([husb gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
						 @"1 FAMS @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects([wife gedcomString], 
                         @"0 @INDI2@ INDI\n"
                         @"1 NAME Anne /Larsdatter/\n"
						 @"1 SEX F\n"
						 @"1 FAMS @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects([chil gedcomString], 
                         @"0 @INDI3@ INDI\n"
                         @"1 NAME Hans /Jensen/\n"
						 @"1 SEX M\n"
						 @"1 FAMC @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
}

- (void)testCoding
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"ged"];
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	NSArray *nodes = [GCNode arrayOfNodesFromString:fileContents];
	
	GCContext *ctx = [GCContext contextWithGedcomNodes:nodes];
    
    NSData *ctxData = [NSKeyedArchiver archivedDataWithRootObject:ctx];
    
    GCContext *decodedCtx = [NSKeyedUnarchiver unarchiveObjectWithData:ctxData];
    
    //NSLog(@"file: %@", [file gedcomString]);
    //NSLog(@"decodedFile: %@", [decodedFile gedcomString]);
    
    STAssertTrue([ctx isEqualTo:decodedCtx], nil);
}

- (void)testObjectValidationWithNodeString:(NSString *)nodeString exceptedErrorCode:(GCErrorCode)errorCode string:(NSString *)errorString
{
    GCContext *ctx = [GCContext context];
    
    NSArray *malformedNodes = [GCNode arrayOfNodesFromString:nodeString];
    
    GCEntity *submitter = [GCEntity entityWithGedcomNode:[malformedNodes lastObject] inContext:ctx];
    
    NSError *error = nil;
    
    BOOL result = [submitter validateObject:&error];
    
    STAssertFalse(result, nil);
    STAssertEqualObjects([[error userInfo] valueForKey:NSLocalizedDescriptionKey], errorString, nil);
    STAssertEquals([error code], errorCode, nil);
}

- (void)testObjectValidation
{
    // Submitter that's missing a required property NAME.
    [self testObjectValidationWithNodeString:@"0 @SUBM1@ SUBM\n"
                                             @"1 LANG English\n"
                                             @"1 LANG Swedish\n"
                                             @"1 LANG Spanish"
                           exceptedErrorCode:GCTooFewValuesError
                                      string:@"Too few values for key name on submitter"];
    
    // Submitter with too many LANG properties.
    [self testObjectValidationWithNodeString:@"0 @SUBM1@ SUBM\n"
                                             @"1 NAME John Doe\n"
                                             @"1 LANG English\n"
                                             @"1 LANG Swedish\n"
                                             @"1 LANG Spanish\n"
                                             @"1 LANG German"
                           exceptedErrorCode:GCTooManyValuesError
                                      string:@"Too many values for key languages on submitter"];
}

@end