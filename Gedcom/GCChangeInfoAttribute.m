//
//  GCChangeInfoAttribute.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCChangeInfoAttribute.h"

#import "GCNode.h"

#import "DateHelpers.h"

@interface GCChangeInfoAttribute ()

@property NSDate *modificationDate;

@end

@implementation GCChangeInfoAttribute

#pragma mark Initialization

- (id)initForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    self = [self init];
    
    if (self) {
        [object.allProperties addObject:self];
        
        self.modificationDate = dateFromNode(node[@"DATE"][0]);
		
        [self addPropertiesWithGedcomNodes:node[@"NOTE"]];
    }
    
    return self;
}

- (id)init
{
	return [super initWithType:@"changeInfo"];
}

+(GCChangeInfoAttribute *)changeInfo
{
	return [self attributeWithType:@"changeInfo"];
}

+(GCChangeInfoAttribute *)changeInfoWithValue:(GCValue *)value
{
	return [self attributeWithType:@"changeInfo" value:value];
}

+(GCChangeInfoAttribute *)changeInfoWithGedcomStringValue:(NSString *)value
{
	return [self attributeWithType:@"changeInfo" gedcomStringValue:value];
}

#pragma mark Gedcom access

- (NSArray *)subNodes
{
	NSArray *subNodes = @[
        nodeFromDate(self.modificationDate),
	];
	
	return [subNodes arrayByAddingObjectsFromArray:super.subNodes];
}

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:nil
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setValueWithGedcomString:(NSString *)string
{
    return;
}

// Properties:
@dynamic noteReferences;
@dynamic noteEmbeddeds;

@end

