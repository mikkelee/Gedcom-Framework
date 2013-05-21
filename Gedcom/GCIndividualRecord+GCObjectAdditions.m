//
//  GCIndividualRecord+GCObjectAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCIndividualRecord+GCObjectAdditions.h"

#import "GCSpouseInFamilyRelationship.h"
#import "GCHusbandRelationship.h"
#import "GCWifeRelationship.h"
#import "GCMarriageAttribute.h"
#import "GCFamilyRecord.h"

@implementation GCIndividualRecord (GCObjectAdditions)

- (GCIndividualRecord *)father
{
    id fathers = [self valueForKeyPath:@"childInFamilies.target.husband.target"];
    id father = [fathers count] > 0 ? fathers[0] : nil;
    return father != [NSNull null] ? father : nil;
}

- (GCIndividualRecord *)mother
{
    id mothers = [self valueForKeyPath:@"childInFamilies.target.wife.target"];
    id mother = [mothers count] > 0 ? mothers[0] : nil;
    return mother != [NSNull null] ? mother : nil;
}

- (NSArray *)parents
{
    NSMutableArray *parents = [NSMutableArray array];
    
    if (self.father) { [parents addObject:self.father]; }
    if (self.mother) { [parents addObject:self.mother]; }
    
    return [parents copy];
}

- (NSArray *)children
{
    return [self valueForKeyPath:@"spouseInFamilies.target.@distinctUnionOfArrays.children.target"];
}

- (BOOL)isDescendantOf:(GCIndividualRecord *)ancestor
{
    for (GCIndividualRecord *parent in self.parents) {
        if (parent == ancestor || [parent isDescendantOf:ancestor]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isAncestorOf:(GCIndividualRecord *)descendant
{
    for (GCIndividualRecord *child in self.children) {
        if (child == descendant || [child isAncestorOf:descendant]) {
            return YES;
        }
    }
    
    return NO;
}

- (GCBirthAttribute *)primaryBirth
{
    id births = [self valueForKeyPath:@"births"];
    return [births count] > 0 ? births[0] : nil;
}

- (GCDeathAttribute *)primaryDeath
{
    id deaths = [self valueForKeyPath:@"deaths"];
    return [deaths count] > 0 ? deaths[0] : nil;
}

- (GCPersonalNameAttribute *)primaryPersonalName
{
    id names = [self valueForKeyPath:@"personalNames"];
    return [names count] > 0 ? names[0] : nil;
}

- (GCDate *)estimatedBirthDate
{
	GCDate *estimatedBirthDate = nil;
	
	// TODO: Make configurable?
	GCAge *infant = [GCAge valueWithGedcomString:@"INFANT"];
	GCAge *teen = [GCAge valueWithGedcomString:@">13y"];
	GCAge *adult = [GCAge valueWithGedcomString:@">18y"];
	
	if ([self.births count] > 0) {
		estimatedBirthDate = [self valueForKeyPath:@"births@primary.date.value"];
	} else if ([self.christenings count] > 0) {
		GCDate *eventDate = [self valueForKeyPath:@"christenings@primary.date.value"];
		estimatedBirthDate = [eventDate dateBySubtractingAge:infant];
	} else if ([self.baptisms count] > 0) {
		GCDate *eventDate = [self valueForKeyPath:@"baptisms@primary.date.value"];
		estimatedBirthDate = [eventDate dateBySubtractingAge:infant];
	} else if ([self.confirmations count] > 0) {
		GCDate *eventDate = [self valueForKeyPath:@"confirmations@primary.date.value"];
		estimatedBirthDate = [eventDate dateBySubtractingAge:teen];
	} else if ([self.spouseInFamilies count] > 0) {
		for (GCSpouseInFamilyRelationship *spouseInFamily in self.spouseInFamilies) {
			for (GCMarriageAttribute *marriage in ((GCFamilyRecord *)spouseInFamily.target).marriages) {
				GCDate *eventDate = [marriage valueForKeyPath:@"date.value"];
				estimatedBirthDate = [eventDate dateBySubtractingAge:adult];
			}
			
		}
	}
	
	if (!estimatedBirthDate) {
		NSLog(@"Unable to estimate a birth date!");
	}
	
	return estimatedBirthDate;
}

- (GCAge *)estimatedAgeOnDate:(id)date
{
	return [GCAge ageFromDate:self.estimatedBirthDate toDate:date];
}

@end
