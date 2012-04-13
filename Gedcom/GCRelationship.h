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

+ (id)relationshipForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

+ (id)relationshipWithType:(NSString *)type;

#pragma mark Properties

@property GCEntity *target;

@end

@interface GCRelationship (GCConvenienceMethods)

+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target;

@end