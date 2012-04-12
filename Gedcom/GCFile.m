//
//  GCFile.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCFile.h"
#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCContext.h"

#import "GCHeader.h"
#import "GCEntity.h"
#import "GCTrailer.h"

@implementation GCFile {
	GCContext *_context;
}

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
		_records = [NSMutableArray arrayWithCapacity:[nodes count]];
		
		for (id node in nodes) {
            GCObject *object = nil;
            if ([[[node gedTag] objectClass] isEqual:[GCHeader class]]) {
                object = [GCHeader headerWithGedcomNode:node inContext:context];
            } else if ([[[node gedTag] objectClass] isEqual:[GCTrailer class]]) {
                object = [GCTrailer trailerWithGedcomNode:node inContext:context];
            } else if ([[[node gedTag] objectClass] isEqual:[GCEntity class]]) {
                object = [GCEntity entityWithGedcomNode:node inContext:context];
            } else {
                NSLog(@"Shouldn't happen! %@ unknown class: %@", node, [[node gedTag] objectClass]);
            }
			[_records addObject:object];
		}
	}
	
	return self;
}

+ (id)fileFromGedcomNodes:(NSArray *)nodes
{
	return [[self alloc] initWithContext:[GCContext context] gedcomNodes:nodes];
}

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[_records count]+2];
	
	//[nodes addObject:[_head gedcomNode]];
	
	for (id record in _records) {
		if ([record isKindOfClass:[GCHeader class]]) {
			//continue;
		} else if ([record isKindOfClass:[GCTrailer class]]) {
			//continue;
		}
		[nodes addObject:[record gedcomNode]];
	}
	
	//TODO trlr
	
	return nodes;
}

@synthesize head = _head;
@synthesize records = _records;

@end
