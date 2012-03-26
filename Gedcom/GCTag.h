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

//helpers:
+ (NSString *)nameForTag:(NSString *)tag;
+ (NSString *)tagForName:(NSString *)name;
+ (NSArray *)aliasesForTag:(NSString *)tag;
+ (NSString *)tagForAlias:(NSString *)tag;
+ (NSArray *)validSubTagsForTag:(NSString *)tag;

//convenience constructors:
+(GCTag *)tagCoded:(NSString *)code;
+(GCTag *)tagNamed:(NSString *)name;

//misc
-(NSOrderedSet *)validSubTags;
-(BOOL)isValidSubTag:(GCTag *)tag;

-(GCValueType)valueType;

//properties
@property (readonly) NSString *code;
@property (readonly) NSString *name;
@property (readonly) BOOL isCustom;

@end
