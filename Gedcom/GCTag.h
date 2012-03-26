//
//  GCTag.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

#import <Foundation/Foundation.h>

@interface GCTag : NSObject <NSCopying, NSCoding>

#pragma mark Convenience constructors

+(GCTag *)tagCoded:(NSString *)code;
+(GCTag *)tagNamed:(NSString *)name;

#pragma mark Helpers

+ (NSString *)codeForName:(NSString *)name;

#pragma mark Subtags

-(BOOL)isValidSubTag:(GCTag *)tag;

#pragma mark Properties

@property (readonly) NSString *code;
@property (readonly) NSString *name;
@property (readonly) BOOL isCustom;
@property (readonly) BOOL isRoot;

@property (readonly) NSOrderedSet *validSubTags;
@property (readonly) GCValueType valueType;

@end
