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

#import "GCContext.h"

@implementation GCFile {
	GCContext *_context;
	NSMutableArray *_records;
}

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
		_records = [NSMutableArray arrayWithCapacity:[nodes count]];
		
		for (id node in nodes) {
			[_records addObject:[GCObject objectWithGedcomNode:node inContext:context]];
		}
	}
	
	return self;
}

+ (id)fileFromGedcomNodes:(NSArray *)nodes
{
	return [[self alloc] initWithContext:[GCContext context] gedcomNodes:nodes];
}

@synthesize head = _head;
@synthesize records = _records;

@end
