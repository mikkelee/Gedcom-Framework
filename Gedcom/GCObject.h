//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCValue.h"

@class GCContext;
@class GCNode;
@class GCTag;
@class GCProperty;

@interface GCObject : NSObject

#pragma mark Initialization

- (id)initWithType:(NSString *)type;

#pragma mark GCProperty access

- (NSOrderedSet *)validProperties;
- (BOOL)allowsMultiplePropertiesOfType:(NSString *)type;

- (void)addProperty:(GCProperty *)property;
- (void)removeProperty:(GCProperty *)property;

#pragma mark Gedcom access

- (NSArray *)subNodes;

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other;

#pragma mark Equality

-(BOOL) isEqualTo:(id)other;

#pragma mark Objective-C properties

@property (readonly) NSString *type;

@property NSMutableOrderedSet *properties;
@property NSMutableOrderedSet *attributes;
@property NSMutableOrderedSet *relationships;

@property (readonly) GCTag *gedTag;
@property (readonly) GCNode *gedcomNode;
@property NSString *gedcomString;

@property (readonly) GCContext *context;

@end

@class GCEntity;
@class GCAge;
@class GCDate;

@interface GCObject (GCConvenienceMethods)

- (void)addAttributeWithType:(NSString *)type value:(GCValue *)value;

- (void)addAttributeWithType:(NSString *)type stringValue:(NSString *)value;
- (void)addAttributeWithType:(NSString *)type numberValue:(NSNumber *)value;
- (void)addAttributeWithType:(NSString *)type ageValue:(GCAge *)value;
- (void)addAttributeWithType:(NSString *)type boolValue:(BOOL)value;
- (void)addAttributeWithType:(NSString *)type dateValue:(GCDate *)value;
- (void)addAttributeWithType:(NSString *)type genderValue:(GCGender)value;

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target;

- (void)addPropertyWithGedcomNode:(GCNode *)node;

@end
