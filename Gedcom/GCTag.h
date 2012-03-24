//
//  GCTag.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCTag : NSObject

-(id)initWithTag:(NSString *)tag;
-(id)initWithName:(NSString *)name;

@property (readonly) NSString *tag;
@property (readonly) NSString *name;
@property (readonly) BOOL isCustom;

@end
