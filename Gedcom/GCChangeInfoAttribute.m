//
//  GCChangeInfoAttribute.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCChangeInfoAttribute.h"

#import "GCNode.h"

#import "GedcomDateHelpers.h"

#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"

#import "GCObject_internal.h"

#import "GCGedcomLoadingAdditions.h"

#import "NSObject+MELazyPropertySwizzlingAdditions.h"

@interface GCChangeInfoAttribute ()

@property NSDate *modificationDate;

@end

@implementation GCChangeInfoAttribute {
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
    
    GCNode *_lazyModificationDateNode;
}

#pragma mark Initialization

+ (void)initialize
{
    [self setupLazyProperties];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _noteReferences = [NSMutableArray array];
        _noteEmbeddeds = [NSMutableArray array];
        _modificationDate = [NSDate date];
    }
    
    return self;
}

- (instancetype)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [self init];
    
    if (self) {
        [object setValue:self forKey:@"changeInfo"];
        
        _modificationDate = nil;
        _lazyModificationDateNode = node[@"DATE"][0];
		
        [self _addPropertiesWithGedcomNodes:node[@"NOTE"]];
    }
    
    return self;
}

#pragma mark NSCoding conformance

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _modificationDate = [aDecoder decodeObjectForKey:@"modificationDate"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_modificationDate forKey:@"modificationDate"];
}

#pragma mark Objective-C properties

- (NSDate *)_lazyModificationDate
{
    return dateFromNode(_lazyModificationDateNode);
}

@synthesize noteReferences = _noteReferences;

- (NSMutableArray *)mutableNoteReferences {
    return [self mutableArrayValueForKey:@"noteReferences"];
}

@synthesize noteEmbeddeds = _noteEmbeddeds;

- (NSMutableArray *)mutableNoteEmbeddeds {
    return [self mutableArrayValueForKey:@"noteEmbeddeds"];
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

@end