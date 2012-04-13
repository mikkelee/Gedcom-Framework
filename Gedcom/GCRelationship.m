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
		//NSLog(@"Set %@ => %@ on %@", xref, [[object context] entityForXref:xref], relationship);
	}];
    
    for (id subNode in [node subNodes]) {
        [[relationship properties] addObject:[GCProperty propertyForObject:relationship withGedcomNode:subNode]];
    }
    
    return relationship;
}

+ (id)relationshipWithType:(NSString *)type
{
	return [[self alloc] initWithType:type];
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    NSParameterAssert([self describedObject]); //something's gone wrong if there's no describedObject
    
    return [[GCNode alloc] initWithTag:[self gedTag]
								 value:[[self context] xrefForEntity:_target]
								  xref:nil
							  subNodes:[self subNodes]];
}

@synthesize target = _target;

@end

@implementation GCRelationship (GCConvenienceMethods)

+ (id)relationshipWithType:(NSString *)type target:(GCEntity *)target
{
    GCRelationship *relationship = [[self alloc] initWithType:type];
    
    [relationship setTarget:target];
	
    return relationship;
}

@end