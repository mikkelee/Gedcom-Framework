//
//  GCRelationship+GCReverseRelationshipAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCChildInFamilyRelationship.h"
#import "GCChildRelationship.h"
#import "GCSpouseInFamilyRelationship.h"
#import "GCHusbandRelationship.h"
#import "GCWifeRelationship.h"
#import "GCIndividualRecord.h"
#import "GCSexAttribute.h"
#import "GCValue.h"

@implementation GCChildInFamilyRelationship (GCReverseRelationshipAdditions)

- (NSString *)reverseRelationshipType
{
    return @"children";
}

@end

@implementation GCChildRelationship (GCReverseRelationshipAdditions)

- (NSString *)reverseRelationshipType
{
    return @"childInFamilies";
}

@end

@implementation GCSpouseInFamilyRelationship (GCReverseRelationshipAdditions)

- (NSString *)reverseRelationshipType
{
    GCGender *gender = (GCGender *)((GCIndividualRecord *)self.rootObject).sex.value;
    NSAssert(!gender || gender != [GCGender unknownGender], @"Gender must be defined, and must not be unknown to add an individual as a spouse to a family.");
    
    return gender == [GCGender maleGender] ? @"husband" : @"wife";
}

@end

@implementation GCHusbandRelationship (GCReverseRelationshipAdditions)

- (NSString *)reverseRelationshipType
{
    return @"spouseInFamilies";
}

@end

@implementation GCWifeRelationship (GCReverseRelationshipAdditions)

- (NSString *)reverseRelationshipType
{
    return @"spouseInFamilies";
}

@end