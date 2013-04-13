//
//  GCIndividualEntity+GCObjectAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCIndividualEntity+GCObjectAdditions.h"

@implementation GCIndividualEntity (GCObjectAdditions)

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
			for (GCMarriageAttribute *marriage in ((GCFamilyEntity *)spouseInFamily.target).marriages) {
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
