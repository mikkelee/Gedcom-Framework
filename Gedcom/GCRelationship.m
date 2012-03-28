//
//  GCRelationnship.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCRelationship.h"

#import "GCNode.h"
#import "GCTag.h"
#import "GCContext.h"

@implementation GCRelationship

#pragma mark Convenience constructors

+ (id)relationshipWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    GCRelationship *object = [[self alloc] initWithType:[[node gedTag] name] inContext:context];
    
	//TODO what about targets not created yet?
    [object setTarget:[context entityForXref:[node xref]]];
    
    for (id subNode in [node subNodes]) {
        [object addProperty:[GCProperty propertyWithGedcomNode:subNode inContext:context]];
    }
    
    return object;
}

+ (id)relationshipWithType:(NSString *)type inContext:(GCContext *)context
{
	return [[self alloc] initWithType:type inContext:context];
}

+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target inContext:(GCContext *)context
{
    GCRelationship *new = [[self alloc] initWithType:type inContext:context];
    
    [new setTarget:target];
    
    return new;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag]
								 value:[[self context] xrefForEntity:target]
								  xref:nil
							  subNodes:[self subNodes]];
}

@synthesize target;

@end
