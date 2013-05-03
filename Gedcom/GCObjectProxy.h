//
//  GCObjectProxy.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 03/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCObject;

@interface GCObjectProxy : NSProxy

- (instancetype)initWitBlock:(GCObject *(^)())block;

@end
