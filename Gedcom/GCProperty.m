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

@implementation GCProperty {
	GCObject *_describedObject;
}

#pragma mark Convenience constructors

+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
	if ([[node gedTag] objectClass] == [GCAttribute class]) {
		return [GCAttribute attributeForObject:object withGedcomNode:node];
	} else if ([[node gedTag] objectClass] == [GCRelationship class]) {
		return [GCRelationship relationshipForObject:object withGedcomNode:node];
	} else {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidObjectClassException"
														 reason:[NSString stringWithFormat:@"Invalid <objectClass> '%@' on %@", [[node gedTag] objectClass], node]
													   userInfo:nil];
		@throw exception;
	}
}

@synthesize describedObject = _describedObject;

@end
