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
#import "GCXrefStore.h"

@implementation GCRelationship

#pragma mark Convenience constructors

+ (id)relationshipWithGedcomNode:(GCNode *)node
{
    GCRelationship *object = [[self alloc] initWithType:[[node gedTag] name]];
    
	//TODO what about targets not created yet?
    [object setTarget:[GCXrefStore entityForXref:[node xref]]];
    
    for (id subNode in [node subNodes]) {
        [object addProperty:[GCProperty propertyWithGedcomNode:subNode]];
    }
    
    return object;
}

+ (id)relationshipWithType:(NSString *)type
{
	return [[self alloc] initWithType:type];
}

+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target
{
    GCRelationship *new = [[self alloc] initWithType:type];
    
    [new setTarget:target];
    
    return new;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag]
								 value:[GCXrefStore xrefForEntity:target]
								  xref:nil
							  subNodes:[self subNodes]];
}

@synthesize target;

@end
