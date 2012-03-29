//
//  GCHead.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeader.h"

@interface GCHeader ()

@property GCNode *gedcomNode;

@end

@implementation GCHeader {
	GCNode *_gedcomNode;
}

+ (id)headerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	GCHeader *head = [[self alloc] init];
	
	[head setGedcomNode:node]; //TODO
	
	return head;
}

@synthesize gedcomNode = _gedcomNode;

@end
