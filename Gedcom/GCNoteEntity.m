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

+ (id)entityWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	GCNoteEntity *note = [super entityWithGedcomNode:node inContext:context];
	
    note.value = [GCString valueWithGedcomString:node.gedValue];
	
	return note;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:self.value.gedcomString
								  xref:[self.context _xrefForEntity:self]
							  subNodes:self.subNodes];
}

#pragma mark Objective-C properties

@dynamic recordIdNumber;
@dynamic userReferenceNumbers;
@dynamic sourceCitations;
@dynamic sourceEmbeddeds;
@dynamic noteReferences;
@dynamic noteEmbeddeds;

@end
