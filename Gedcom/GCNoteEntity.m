//
//  GCNoteEntity.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 17/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNoteEntity.h"
#import "GCString.h"
#import "GCNode.h"
#import "GCContext_internal.h"

@implementation GCNoteEntity

#pragma mark Initialization

- (id)init
{
	return [super initWithType:@"note"];
}

#pragma mark Convenience constructors

+(GCNoteEntity *)noteInContext:(GCContext *)context
{
	return [self entityWithType:@"note" inContext:context];
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:nil
								  xref:[self.context xrefForEntity:self]
							  subNodes:self.subNodes];
}

- (NSOrderedSet *)subNodes
{
    NSMutableOrderedSet *subNodes = [[super subNodes] mutableCopy];
    
    [subNodes insertObject:[GCNode nodeWithTag:@"CONC" value:self.value.gedcomString] atIndex:0];
    
    return [subNodes copy];
}

#pragma mark Objective-C properties

@dynamic recordIdNumber;
@dynamic userReferenceNumbers;
@dynamic sources;
@dynamic sourceCitations;
@dynamic sourceEmbeddeds;
@dynamic notes;
@dynamic noteReferences;
@dynamic noteEmbeddeds;

@end