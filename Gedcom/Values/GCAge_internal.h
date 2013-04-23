//
//  GCAge_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

#define DebugLog(fmt, ...) if (0) NSLog(fmt, ## __VA_ARGS__)

#pragma mark Private methods

@class GCSimpleAge;

typedef enum : NSInteger {
    GCAgeLessThan,
    GCAgeNoQualifier,
    GCAgeGreaterThan
} GCAgeQualifier;

@interface GCAge ()

- (instancetype)initWithSimpleAge:(NSDateComponents *)c qualifier:(GCAgeQualifier)q;
- (instancetype)initWithAgeKeyword:(NSString *)s qualifier:(GCAgeQualifier)q;
- (instancetype)initWithInvalidAgeString:(NSString *)s;

+ (id)ageWithSimpleAge:(NSDateComponents *)c qualifier:(GCAgeQualifier)q;
+ (id)ageWithAgeKeyword:(NSString *)p qualifier:(GCAgeQualifier)q;
+ (id)ageWithInvalidAgeString:(NSString *)s;

@property (readonly) GCSimpleAge *refAge; //used for sorting, etc.

@end

#pragma mark GCSimpleAge

@interface GCSimpleAge : GCAge

@property GCAgeQualifier qualifier;
@property NSDateComponents *ageComponents;

@end

#pragma mark GCAgeKeyword

@interface GCAgeKeyword : GCAge

@property GCAgeQualifier qualifier;
@property (copy) NSString *keyword;

@end

#pragma mark GCInvalidAge

@interface GCInvalidAge : GCAge

@property NSString *string;

@end

#pragma mark GCAgeParser

@interface GCAgeParser : NSObject

+ (GCAgeParser *)sharedAgeParser;
- (GCAge *)parseGedcom:(NSString *)g;

@end
