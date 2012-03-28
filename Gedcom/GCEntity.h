//
//  GCObject.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

@interface GCEntity : GCObject

#pragma mark Convenience constructors

+ (id)entityWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

+ (id)entityWithType:(NSString *)type inContext:(GCContext *)context;

@end
