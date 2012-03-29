//
//  GCAge.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    GCAgeLessThan,
    GCAgeGreaterThan
} GCAgeQualifier;

@interface GCAge : NSObject <NSCoding, NSCopying>

//generally you should use this:

+ (GCAge *)ageFromGedcom:(NSString *)gedcom;

//convenience factory methods:

- (id)initWithGedcom:(NSString *)gedcom;
- (id)initWithSimpleAge:(NSDateComponents *)c;
- (id)initWithAgeKeyword:(NSString *)s;
- (id)initWithInvalidAgeString:(NSString *)s;
- (id)initWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q;

+ (id)ageWithSimpleAge:(NSDateComponents *)c;
+ (id)ageWithAgeKeyword:(NSString *)p;
+ (id)ageWithInvalidAgeString:(NSString *)s;
+ (id)ageWithAge:(GCAge *)a withQualifier:(GCAgeQualifier)q;

- (NSComparisonResult)compare:(id)other;

@property (retain, readonly) NSString *gedcomString;
@property (retain, readonly) NSString *displayString;
@property (retain, readonly) NSString *description;

@property (readonly) NSUInteger years;
@property (readonly) NSUInteger months;
@property (readonly) NSUInteger days;

@end
