//
//  GCTrailer.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTrailer.h"

@interface GCTrailer ()

@property GCNode *gedcomNode;

@end

@implementation GCTrailer {
	GCNode *_gedcomNode;
}

+ (id)trailerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	GCTrailer *trailer = [[self alloc] init];
	
	[trailer setGedcomNode:node]; //TODO
	
	return trailer;
}

@synthesize gedcomNode = _gedcomNode;

@end
