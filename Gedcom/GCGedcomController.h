//
//  GedcomController.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCGedcomController : NSObject

+ (id)sharedController;

+ (NSString *)nameForTag:(NSString *)tag;
+ (NSString *)tagForName:(NSString *)name;
+ (NSArray *)aliasesForTag:(NSString *)tag;
+ (NSString *)tagForAlias:(NSString *)tag;
+ (NSArray *)validSubTagsForTag:(NSString *)tag;

@property (readonly) NSDictionary *tags;

@end
