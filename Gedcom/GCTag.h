//
//  GCTag.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCTag : NSObject <NSCopying, NSCoding>

+(GCTag *)tagCoded:(NSString *)code;
+(GCTag *)tagNamed:(NSString *)name;

-(NSArray *)validSubTags;
-(BOOL)isValidSubTag:(GCTag *)tag;

@property (readonly) NSString *code;
@property (readonly) NSString *name;
@property (readonly) BOOL isCustom;

@end
