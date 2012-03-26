//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCNode;
@class GCValue;
@class GCAge;
@class GCDate;

@interface GCRecord : NSObject

+ (id)objectWithGedcomNode:(GCNode *)node;

+ (id)objectWithType:(NSString *)type;
+ (id)objectWithType:(NSString *)type value:(GCValue *)value;
+ (id)objectWithType:(NSString *)type stringValue:(NSString *)value;
+ (id)objectWithType:(NSString *)type numberValue:(NSNumber *)value;
+ (id)objectWithType:(NSString *)type ageValue:(GCAge *)value;
+ (id)objectWithType:(NSString *)type dateValue:(GCDate *)value;
+ (id)objectWithType:(NSString *)type boolValue:(BOOL)value;

+ (id)objectWithType:(NSString *)type object:(GCRecord *)object;

- (void)addRecord:(GCRecord *)object;
- (void)addRecordWithType:(NSString *)type stringValue:(NSString *)value;
- (void)addRecordWithType:(NSString *)type numberValue:(NSNumber *)value;
- (void)addRecordWithType:(NSString *)type ageValue:(GCAge *)value;
- (void)addRecordWithType:(NSString *)type dateValue:(GCDate *)value;
- (void)addRecordWithType:(NSString *)type boolValue:(BOOL)value;

- (void)addRecordWithType:(NSString *)type object:(GCRecord *)object;

- (NSArray *)validSubRecordTypes;

- (GCNode *)gedcomNode;

@property (readonly) NSString *type;
@property (readonly) BOOL isRoot;

@property GCValue *value;
@property NSString *stringValue;
@property NSNumber *numberValue;
@property GCAge *ageValue;
@property GCDate *dateValue;
@property BOOL boolValue;

@end
