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

@implementation GCRelationship

#pragma mark Convenience constructors

+ (id)relationshipWithGedcomNode:(GCNode *)node
{
	return nil; //TODO
}

+ (id)relationshipWithType:(NSString *)type object:(GCObject *)object
{
	return nil; //TODO
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag]
								 value:nil //TODO
								  xref:nil
							  subNodes:[self subNodes]];
}

@end
