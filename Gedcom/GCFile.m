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
}

- (id)initWithContext:(GCContext *)context
{
	self = [super init];
	
	if (self) {
		_context = context;
	}
	
	return self;
}

+ (id)fileFromGedcomNodes:(NSArray *)nodes
{
	GCFile *new = [[self alloc] initWithContext:[[GCContext alloc] init]];
	
	//TODO
	
	return new;
}

@synthesize head = _head;
@synthesize records = _records;

@end
