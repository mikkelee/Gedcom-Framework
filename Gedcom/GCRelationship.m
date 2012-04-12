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

@implementation GCRelationship {
	GCEntity *_target;
}

#pragma mark Convenience constructors

+ (id)relationshipForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    GCRelationship *relationship = [[self alloc] initWithType:[[node gedTag] name]];
    
	[relationship setDescribedObject:object];
	
	[[object context] registerXref:[node gedValue] forBlock:^(NSString *xref) {
		GCEntity *target = [[object context] entityForXref:xref];
		[relationship setTarget:target];
		NSLog(@"Set %@ => %@ on %@", xref, [[object context] entityForXref:xref], relationship);
	}];
    
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
	NSParameterAssert([object context] == [target context]);
	
    GCRelationship *relationship = [[self alloc] initWithType:type];
    
	[relationship setDescribedObject:object];
    [relationship setTarget:target];
	
    return relationship;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag]
								 value:[[self context] xrefForEntity:_target]
								  xref:nil
							  subNodes:[self subNodes]];
}

@synthesize target = _target;

@end
