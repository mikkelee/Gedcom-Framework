//
//  GCProperty.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

#import "GCNode.h"
#import "GCTag.h"

#import "GCAttribute.h"
#import "GCRelationship.h"

@implementation GCProperty 

#pragma mark Convenience constructors

+ (id)propertyWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	if ([[node gedTag] objectClass] == [GCAttribute class]) {
		return [GCAttribute attributeWithGedcomNode:node inContext:context];
	} else if ([[node gedTag] objectClass] == [GCRelationship class]) {
		return [GCRelationship relationshipWithGedcomNode:node inContext:context];
	} else {
		return nil;
	}
}

@synthesize object = _object;

@end
