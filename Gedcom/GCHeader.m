//
//  GCHead.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeader.h"

#import "GCNode.h"

@interface GCHeader ()

@property GCNode *gedcomNode;

@end

@implementation GCHeader {
	GCNode *_gedcomNode;
}

#pragma mark Convenience constructors

+ (id)headerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    NSParameterAssert([[node gedTag] isEqualToString:@"HEAD"]);
    
	GCHeader *head = [[self alloc] init];
	
	[head setGedcomNode:node]; //TODO
	
	return head;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        _gedcomNode = [aDecoder decodeObjectForKey:@"gedcomNode"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_gedcomNode forKey:@"gedcomNode"];
}

#pragma mark Objective-C properties

@synthesize gedcomNode = _gedcomNode;

@end
