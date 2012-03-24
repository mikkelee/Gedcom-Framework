//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCNode;

@interface GCObject : NSObject

+ (id)objectWithType:(NSString *)type;

- (void)addRecord:(GCObject *)object;

- (GCNode *)gedcomNode;

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key; //search internally for key, for example "Birth"
- (void)setNilValueForKey:(NSString *)key; //delete internal record
- (void)setValue:(id)value forUndefinedKey:(NSString *)key; //create internal record

@property NSString *type;

@property NSString *stringValue;

@end
