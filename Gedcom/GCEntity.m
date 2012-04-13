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

@implementation GCEntity {
    GCContext *_context;
}

#pragma mark Initialization

- (id)initWithType:(NSString *)type inContext:(GCContext *)context
{
    self = [super initWithType:type];
    
    if (self) {
		_context = context;
    }
    
    return self;    
}

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
        [[entity properties] addObject:[GCProperty propertyForObject:entity withGedcomNode:subNode]];
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

@synthesize context = _context;

@end
