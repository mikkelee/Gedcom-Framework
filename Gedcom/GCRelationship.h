//
//  GCRelationnship.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCProperty.h"

#import "GCEntity.h"

@interface GCRelationship : GCProperty

#pragma mark Convenience constructors

+ (id)relationshipWithGedcomNode:(GCNode *)node;

+ (id)relationshipWithType:(NSString *)type;
+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target;

@property GCEntity *target;

@end
