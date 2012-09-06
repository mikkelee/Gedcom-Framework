//
//  GCAge_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAge.h"

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

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

#pragma mark GCSimpleAge

@interface GCSimpleAge : GCAge

@property NSDateComponents *ageComponents;

@end

#pragma mark GCQualifiedAge

@interface GCQualifiedAge : GCAge

@property GCAge * age;
@property GCAgeQualifier qualifier;

@end

#pragma mark GCAgeKeyword

@interface GCAgeKeyword : GCAge

@property (copy) NSString *keyword;

@end

#pragma mark GCInvalidAge

@interface GCInvalidAge : GCAge

@property NSString *string;

@end

