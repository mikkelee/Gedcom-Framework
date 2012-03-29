//
//  GCHead.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHead.h"

@interface GCHead ()

@property GCNode *gedcomNode;

@end

@implementation GCHead {
	GCNode *_gedcomNode;
}

+ (id)headWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	GCHead *head = [[self alloc] init];
	
	[head setGedcomNode:node]; //TODO
	
	return head;
}

@synthesize gedcomNode = _gedcomNode;

@end
