//
//  GCHead.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeader.h"

#import "GCNode.h"

#import "GCContext.h"

@implementation GCHeader {
    GCContext *_context;
}

#pragma mark Initialization

- (id)initInContext:(GCContext *)context
{
    self = [super initWithType:@"headerRecord"];
    
    if (self) {
        _context = context;
    }
    
    return self;
}

#pragma mark Convenience constructors

+ (id)headerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    NSParameterAssert([[node gedTag] isEqualToString:@"HEAD"]);
    
	GCHeader *head = [[self alloc] initInContext:context];
	
	[head addPropertiesWithGedcomNodes:[node subNodes]];
	
	return head;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithType:@"headerRecord"];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
        [self decodeProperties:aDecoder];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_context forKey:@"context"];
    [self encodeProperties:aCoder];
}

#pragma mark Objective-C Properties

@synthesize context = _context;

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:@"HEAD"
								 value:nil
								  xref:nil
							  subNodes:[self subNodes]];
}

@end
