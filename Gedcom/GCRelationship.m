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

+ (id)relationshipForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCRelationship *relationship = [[self alloc] initWithType:[[node gedTag] name] inContext:[object context]];
    
	[relationship setDescribedObject:object];
	//TODO what about targets not created yet?
    [relationship setTarget:[[object context] entityForXref:[node xref]]];
    
    for (id subNode in [node subNodes]) {
        [relationship addProperty:[GCProperty propertyForObject:object withGedcomNode:subNode]];
    }
    
    return relationship;
}

+ (id)relationshipForObject:(GCObject *)object withType:(NSString *)type
{
	return [[self alloc] initWithType:type inContext:[object context]];
}

+ (id)relationshipForObject:(GCObject *)object withType:(NSString *)type target:(GCEntity *)target
{
    GCRelationship *new = [[self alloc] initWithType:type inContext:[object context]];
    
	[new setDescribedObject:object];
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
