//
//  GCHead.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeader.h"

#import "GCObject_internal.h"

#import "GCNode.h"

#import "GCContext.h"

@implementation GCHeader {
    GCContext *_context;
}

#pragma mark Initialization

- (id)initInContext:(GCContext *)context
{
    self = [super initWithType:@"header"];
    
    if (self) {
        _context = context;
    }
    
    return self;
}

#pragma mark Convenience constructors

+ (id)headerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    NSParameterAssert([[node gedTag] isEqualToString:@"HEAD"]);
    
	GCHeader *header = [[self alloc] initInContext:context];
	
    //TODO clean up this part:
    __block GCNode *dateNode = nil;
    
    [[node subNodes] enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GCNode *subNode = (GCNode *)obj;
        if ([[subNode gedTag] isEqualToString:@"DATE"]) {
            dateNode = subNode;
            *stop = YES;
        }
    }];
    
    NSMutableOrderedSet *subNodesWithoutDate = [[node subNodes] mutableCopy];
    
    [subNodesWithoutDate removeObject:dateNode];
    
    [header addPropertiesWithGedcomNodes:subNodesWithoutDate];
    
    //TODO actually use dateNode (see GCEntity for example)
    
	return header;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_context forKey:@"context"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSString *indent = @"";
    for (NSUInteger i = 0; i < level; i++) {
        indent = [NSString stringWithFormat:@"%@%@", indent, @"  "];
    }
    
    return [NSString stringWithFormat:@"%@<%@: %p> {\n%@%@};\n", indent, NSStringFromClass([self class]), self, [self propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

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
