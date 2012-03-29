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

#import "GCContext.h"

@implementation GCEntity 

#pragma mark Convenience constructors

+ (id)entityWithType:(NSString *)type inContext:(GCContext *)context
{
    return [[self alloc] initWithType:type inContext:context];
}

+ (id)entityWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    GCEntity *entity = [[self alloc] initWithType:[[node gedTag] name] inContext:context];
    
	[context storeXref:[node xref] forEntity:entity];
	
    for (id subNode in [node subNodes]) {
        [entity addProperty:[GCProperty propertyForObject:entity withGedcomNode:subNode]];
    }
    
    return entity;
}

#pragma mark Properties

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag] 
								 value:nil
								  xref:[[self context] xrefForEntity:self]
							  subNodes:[self subNodes]];
}

@end
