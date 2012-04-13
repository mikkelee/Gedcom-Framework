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
            Class objectClass = [[node gedTag] objectClass];
            
            if ([objectClass isEqual:[GCHeader class]]) {
                if (_head) {
                    NSLog(@"Multiple headers!?");
                }
                _head = [GCHeader headerWithGedcomNode:node inContext:context];
            } else if ([objectClass isEqual:[GCEntity class]]) {
                [_records addObject:[GCEntity entityWithGedcomNode:node inContext:context]];
            } else if ([objectClass isEqual:[GCTrailer class]]) {
                continue; //ignore trailer... 
            } else {
                NSLog(@"Shouldn't happen! %@ unknown class: %@", node, [[node gedTag] objectClass]);
            }
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
	
	[nodes addObject:[_head gedcomNode]];
	
	for (id record in _records) {
		[nodes addObject:[record gedcomNode]];
	}
	
    [nodes addObject:[GCNode nodeWithTag:[GCTag tagNamed:@"Trailer"] value:nil]];
    
	return nodes;
}

@synthesize head = _head;
@synthesize records = _records;

@end
