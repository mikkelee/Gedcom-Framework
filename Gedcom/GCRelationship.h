//
//  GCRelationnship.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCProperty.h"

@interface GCRelationship : GCProperty

#pragma mark Convenience constructors

+ (id)relationshipWithGedcomNode:(GCNode *)node;

+ (id)relationshipWithType:(NSString *)type object:(GCObject *)object;


@end
