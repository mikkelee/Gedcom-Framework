//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCValue.h"

@class GCNode;

@class GCContext;
@class GCAge;
@class GCDate;
@class GCTag;
@class GCEntity;
@class GCProperty;
@class GCAttribute;
@class GCRelationship;

@interface GCObject : NSObject

#pragma mark Initialization

- (id)initWithType:(NSString *)type;

#pragma mark GCProperty access

- (NSOrderedSet *)validProperties;
- (BOOL)allowsMultiplePropertiesOfType:(NSString *)type;

- (void)addProperty:(GCProperty *)property;
- (void)removeProperty:(GCProperty *)property;

- (void)addAttributeWithType:(NSString *)type stringValue:(NSString *)value;
- (void)addAttributeWithType:(NSString *)type numberValue:(NSNumber *)value;
- (void)addAttributeWithType:(NSString *)type ageValue:(GCAge *)value;
- (void)addAttributeWithType:(NSString *)type boolValue:(BOOL)value;
- (void)addAttributeWithType:(NSString *)type dateValue:(GCDate *)value;
- (void)addAttributeWithType:(NSString *)type genderValue:(GCGender)value;

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target;

#pragma mark Gedcom access

- (NSArray *)subNodes;

#pragma mark Cocoa properties

@property (readonly) NSString *type;

@property NSMutableOrderedSet *properties;
@property NSMutableOrderedSet *attributes;
@property NSMutableOrderedSet *relationships;

@property (readonly) GCTag *gedTag;
@property (readonly) GCNode *gedcomNode;

@property (readonly) GCContext *context;

@end
