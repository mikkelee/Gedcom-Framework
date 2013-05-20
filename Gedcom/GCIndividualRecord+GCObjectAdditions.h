//
//  GCIndividualRecord+GCObjectAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCIndividualRecord.h"
#import "GCValue.h"

@interface GCIndividualRecord (GCObjectAdditions)

@property (readonly, nonatomic) GCIndividualRecord *father;
@property (readonly, nonatomic) GCIndividualRecord *mother;
@property (readonly, nonatomic) NSArray *children;

/// Attempts to estimate the birth date based on the events attached to the individual
@property (readonly) GCDate *estimatedBirthDate;

/** Attemts to estimate how old the individual was on a given date
 
 @param date The date to test against.
 @return The age on the given date.
 */
- (GCAge *)estimatedAgeOnDate:(id)date;

@end
