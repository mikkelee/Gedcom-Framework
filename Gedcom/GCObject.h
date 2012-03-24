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

@property NSString *type;

@property NSString *stringValue;

@end
