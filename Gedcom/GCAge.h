//
//  GCAge.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCSimpleAge;
@class GCAgeKeyword;
@class GCInvalidAge;
@class GCQualifiedAge;

enum {
    GCAgeLessThan,
    GCAgeGreaterThan
};
typedef NSUInteger GCAgeQualifier;

@interface GCAge : NSObject {

}

//generally you should use this:

+ (GCAge *)ageFromGedcom:(NSString *)gedcom;

//convenience factory methods:

+ (GCSimpleAge *)simpleAge:(NSDateComponents *)c;
+ (GCAgeKeyword *)ageKeyword:(NSString *)p;
+ (GCInvalidAge *)invalidAgeString:(NSString *)s;
+ (GCQualifiedAge *)age:(GCAge *)a withQualifier:(GCAgeQualifier)q;

- (NSComparisonResult)compare:(id)other;

//subclasses implement these:

@property (retain, readonly) GCSimpleAge *refAge; //used for sorting, etc.

@property (retain, readonly) NSString *gedcomString;
@property (retain, readonly) NSString *displayString;
@property (retain, readonly) NSString *description;

@end
