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

+(GCTag *)tagWithType:(NSString *)type code:(NSString *)code;

#pragma mark Entry points

+(GCTag *)tagNamed:(NSString *)name;
+(GCTag *)rootTagWithCode:(NSString *)code;

#pragma mark Subtags

-(GCTag *)subTagWithCode:(NSString *)code;
-(GCTag *)subTagWithName:(NSString *)name;

#pragma mark Subtags

-(BOOL)isValidSubTag:(GCTag *)tag;
-(BOOL)allowsMultipleSubtags:(GCTag *)tag;

#pragma mark Properties

@property (readonly) NSString *code;
@property (readonly) NSString *name;
@property (readonly) BOOL isCustom;

@property (readonly) NSOrderedSet *validSubTags;
@property (readonly) GCValueType valueType;
@property (readonly) Class objectClass;
@property (readonly) GCTag *reverseRelationshipTag;

@end
