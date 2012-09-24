//
//  GCCustomEntity.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 18/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCCustomEntity.h"

@implementation GCCustomEntity

#pragma mark Convenience constructors

+ (id)entityWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	GCCustomEntity *entity = [super entityWithGedcomNode:node inContext:context];
	
    entity.value = [GCString valueWithGedcomString:node.gedValue];
	
	return entity;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:self.value.gedcomString
								  xref:nil
							  subNodes:self.subNodes];
}

@end
