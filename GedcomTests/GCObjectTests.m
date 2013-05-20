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
    GCAttribute *date = [[GCDateAttribute alloc] init];
    
    date.value = [GCDate valueWithGedcomString:@"1 JAN 1901"];
    
    STAssertEqualObjects(date.value.gedcomString, @"1 JAN 1901", nil);
    
    GCAttribute *name = [GCPersonalNameAttribute personalNameWithGedcomStringValue:@"Jens /Hansen/ Smed"];
    
    STAssertEqualObjects(name.value.displayString, @"Hansen, Jens (Smed)", nil);
}

- (void)testSimpleObjects
{
    // Create a context.
	GCContext *ctx = [GCContext context];
	
    // Create an individual entity in the context.
    GCIndividualRecord *indi = [GCIndividualRecord individualInContext:ctx];
    
    // Create an array of names and add them to the individual under "personalNames".
    [indi addAttributeWithType:@"personalNames" values:
     [GCNamestring valueWithGedcomString:@"Jens /Hansen/"],
     [GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"],
     nil];
    
    // Create a birth attribute, give it a date attribute and add it to the individual.
	GCBirthAttribute *birt = [GCBirthAttribute birth];
    
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    
    [indi.mutableProperties addObject:birt];
    
    [indi addAttributeWithType:@"deaths" value:[GCBool yes]];
    
    // Setting a known date so output is testable:
    [indi setValue:[NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00 +0000"] forKey:@"modificationDate"];
    
    STAssertEqualObjects(indi.gedcomString,
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
    
    //NSLog(@"indi individualEvents: %@", indi.individualEvents);
    
    ctx = [GCContext context]; //fresh context
	
    GCNode *node = [GCNode nodeWithTag:@"INDI"
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
    
    GCRecord *object = [GCIndividualRecord newWithGedcomNode:node inContext:ctx];
    
    STAssertEqualObjects(node.gedcomString, object.gedcomString, nil);
    
    STAssertEqualObjects(object.gedcomString,
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
	
	GCIndividualRecord *husb = [GCIndividualRecord individualInContext:ctx];
	[husb addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[husb addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
	GCIndividualRecord *wife = [GCIndividualRecord individualInContext:ctx];
	[wife addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Anne /Larsdatter/"]];
	[wife addAttributeWithType:@"sex" value:[GCGender femaleGender]];
	
	GCIndividualRecord *chil = [GCIndividualRecord individualInContext:ctx];
	[chil addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Hans /Jensen/"]];
	[chil addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
    GCFamilyRecord *fam = [GCFamilyRecord familyInContext:ctx];
    
	[fam addRelationshipWithType:@"husband" target:husb];
	[fam addRelationshipWithType:@"wife" target:wife];
	[fam addRelationshipWithType:@"child" target:chil];
    
    // alternately:
	// [husb addRelationshipWithType:@"spouseInFamily" target:fam];
	// [wife addRelationshipWithType:@"spouseInFamily" target:fam];
	// [chil addRelationshipWithType:@"childInFamily" target:fam];
	
    //Setting known dates
    NSDate *knownDate = [NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00 +0000"];
    [fam setValue:knownDate forKey:@"modificationDate"];
    [husb setValue:knownDate forKey:@"modificationDate"];
    [wife setValue:knownDate forKey:@"modificationDate"];
    [chil setValue:knownDate forKey:@"modificationDate"];

    STAssertEqualObjects(fam.gedcomString,
                         @"0 @FAM1@ FAM\n"
                         @"1 HUSB @INDI1@\n"
                         @"1 WIFE @INDI2@\n"
                         @"1 CHIL @INDI3@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects(husb.gedcomString,
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
						 @"1 SEX M\n"
						 @"1 FAMS @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects(wife.gedcomString,
                         @"0 @INDI2@ INDI\n"
                         @"1 NAME Anne /Larsdatter/\n"
						 @"1 SEX F\n"
						 @"1 FAMS @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
	
    STAssertEqualObjects(chil.gedcomString,
                         @"0 @INDI3@ INDI\n"
                         @"1 NAME Hans /Jensen/\n"
						 @"1 SEX M\n"
						 @"1 FAMC @FAM1@\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
    STAssertEqualObjects(chil.father, husb, nil);
    STAssertEqualObjects(chil.mother, wife, nil);
    STAssertEquals([husb.children count], (NSUInteger)1, nil);
    STAssertEquals([wife.children count], (NSUInteger)1, nil);
    STAssertEqualObjects(husb.children[0], chil, nil);
    STAssertEqualObjects(wife.children[0], chil, nil);
}

// TODO cleanup:
- (void)testObjectValidationWithNodeString:(NSString *)nodeString exceptedErrorCode:(GCErrorCode)errorCode string:(NSString *)errorString
{
    GCContext *ctx = [GCContext context];
    
    NSArray *malformedNodes = [GCNodeParser arrayOfNodesFromString:nodeString];
    
    GCRecord *submitter = [GCSubmitterRecord newWithGedcomNode:[malformedNodes lastObject] inContext:ctx];
    
    NSError *error = nil;
    
    BOOL result = [submitter validateObject:&error];
    
    //NSLog(@"error: %@", error);
    
    STAssertFalse(result, nil);
    STAssertEquals([error code], (NSInteger)NSValidationMultipleErrorsError, nil);
    STAssertEqualObjects([error localizedDescription], @"Multiple validation errors occurred.", nil);
    
    STAssertEquals([(NSArray *)[error userInfo][NSDetailedErrorsKey] count], (NSUInteger)2, nil);
    
    STAssertEquals([(NSError *)[error userInfo][NSDetailedErrorsKey][1] code], GCTooFewValuesError, nil);
    STAssertEqualObjects([[error userInfo][NSDetailedErrorsKey][1] localizedDescription], @"Too few values for key descriptiveName on submitter", nil);
    
    STAssertEquals([(NSError *)[error userInfo][NSDetailedErrorsKey][0] code], GCTooManyValuesError, nil);
    STAssertEqualObjects([[error userInfo][NSDetailedErrorsKey][0] localizedDescription], @"Too many values for key languages on submitter", nil);
}

- (void)testObjectValidation
{
    // Submitter that's missing a required property NAME.
    [self testObjectValidationWithNodeString:@"0 @SUBM1@ SUBM\n"
                                             @"1 LANG English\n"
                                             @"1 LANG Swedish\n"
                                             @"1 LANG Spanish\n"
                                             @"1 LANG German"
                           exceptedErrorCode:GCTooFewValuesError
                                      string:@"Too few values for key name on submitter"];
    
}

- (void)testDescribedObject
{
	GCContext *ctx = [GCContext context];
	
    GCIndividualRecord *indi = [GCIndividualRecord individualInContext:ctx];
    
    [indi addAttributeWithType:@"sex" value:[GCGender valueWithGedcomString:@"M"]];
    
    GCAttribute *name = [GCPersonalNameAttribute personalNameWithGedcomStringValue:@"Jens /Hansen/"];
    
    STAssertNil(name.describedObject, nil);
    
    [indi.mutablePersonalNames addObject:name];
    
    STAssertEqualObjects(name.describedObject, indi, nil);
    
    [indi.mutablePersonalNames removeObject:name];
    
    STAssertNil(name.describedObject, nil);
}

- (void)testLocalization
{
	GCContext *ctx = [GCContext context];
    
    GCIndividualRecord *indi = [GCIndividualRecord individualInContext:ctx];
    
    STAssertEqualObjects(indi.localizedType, @"Individual", nil);
    
    GCAncestralFileNumberAttribute *afn = [GCAncestralFileNumberAttribute ancestralFileNumber];
    
    STAssertEqualObjects(afn.localizedType, @"Ancestral File number", nil);
}

- (void)testGetterSetter
{
    GCBirthAttribute *birt = [GCBirthAttribute birth];
    
    birt.place = [GCPlaceAttribute placeWithGedcomStringValue:@"Denmark"];
    
    STAssertEqualObjects(birt.place.value.gedcomString, @"Denmark", nil);
}

@end