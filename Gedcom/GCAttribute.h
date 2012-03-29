//
//  GCAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"
#import "GCValue.h"

@class GCAge;
@class GCDate;

@interface GCAttribute : GCProperty

#pragma mark Convenience constructors

+ (id)attributeForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type;

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type value:(GCValue *)value;

+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type stringValue:(NSString *)value;
+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type numberValue:(NSNumber *)value;
+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type ageValue:(GCAge *)value;
+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type dateValue:(GCDate *)value;
+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type boolValue:(BOOL)value;
+ (id)attributeForObject:(GCObject *)object withType:(NSString *)type genderValue:(GCGender)value;

#pragma mark Properties

@property GCValue *value;
@property NSString *stringValue;
@property NSNumber *numberValue;
@property GCAge *ageValue;
@property GCDate *dateValue;
@property BOOL boolValue;
@property GCGender genderValue;

@end
