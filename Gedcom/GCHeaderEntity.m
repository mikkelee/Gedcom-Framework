//
//  GCHead.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeaderEntity.h"

#import "GCObject_internal.h"

#import "GCNode.h"
#import "GCTag.h"

@implementation GCHeaderEntity

#pragma mark Convenience constructors

+ (id)headerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    NSParameterAssert(context);
    NSParameterAssert(node);
    
	return [self entityWithGedcomNode:node inContext:context];
}

#pragma mark Description

//COV_NF_START
- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSString *indent = @"";
    for (NSUInteger i = 0; i < level; i++) {
        indent = [NSString stringWithFormat:@"%@%@", indent, @"  "];
    }
    
    return [NSString stringWithFormat:@"%@<%@: %p> {\n%@%@};\n", indent, [self className], self, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark Objective-C Properties

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:nil
								  xref:nil
							  subNodes:self.subNodes];
}

@dynamic headerSource;
@dynamic destinations;
@dynamic headerDate;
@dynamic submitterReference;
@dynamic submissionReferences;
@dynamic file;
@dynamic copyright;
@dynamic gedcom;
@dynamic characterSet;
@dynamic language;
@dynamic noteEmbedded;

@end
