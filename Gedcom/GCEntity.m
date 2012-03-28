//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCXRefStore.h"

@implementation GCEntity 

#pragma mark Convenience constructors

+ (id)entityWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

+ (id)entityWithGedcomNode:(GCNode *)node
{
    GCEntity *object = [[self alloc] initWithType:[[node gedTag] name]];
    
    for (id subNode in [node subNodes]) {
        [object addProperty:[GCProperty propertyWithGedcomNode:subNode]];
    }
    
    return object;
}

#pragma mark Properties

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag] 
								 value:nil
								  xref:[GCXrefStore xrefForEntity:self]
							  subNodes:[self subNodes]];
}

@end
