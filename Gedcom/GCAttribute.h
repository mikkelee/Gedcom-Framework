//
//  GCAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

@class GCValue;
@class GCAge;
@class GCDate;

@interface GCAttribute : GCProperty

#pragma mark Convenience constructors

+ (id)attributeWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

+ (id)attributeWithType:(NSString *)type inContext:(GCContext *)context;

+ (id)attributeWithType:(NSString *)type value:(GCValue *)value inContext:(GCContext *)context;

+ (id)attributeWithType:(NSString *)type stringValue:(NSString *)value inContext:(GCContext *)context;
+ (id)attributeWithType:(NSString *)type numberValue:(NSNumber *)value inContext:(GCContext *)context;
+ (id)attributeWithType:(NSString *)type ageValue:(GCAge *)value inContext:(GCContext *)context;
+ (id)attributeWithType:(NSString *)type dateValue:(GCDate *)value inContext:(GCContext *)context;
+ (id)attributeWithType:(NSString *)type boolValue:(BOOL)value inContext:(GCContext *)context;

#pragma mark Properties

@property GCValue *value;
@property NSString *stringValue;
@property NSNumber *numberValue;
@property GCAge *ageValue;
@property GCDate *dateValue;
@property BOOL boolValue;

@end
