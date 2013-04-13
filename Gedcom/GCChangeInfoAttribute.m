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

#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"

#import "GCObject_internal.h"

#import "GCProperty_internal.h"

@interface GCChangeInfoAttribute ()

@property NSDate *modificationDate;

@end

@implementation GCChangeInfoAttribute {
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

#pragma mark Initialization

- (id)_init
{
	self = [super _initWithType:@"changeInfo"];
    
    if (self) {
        _noteReferences = [NSMutableArray array];
        _noteEmbeddeds = [NSMutableArray array];
    }
    
    return self;
}

- (id)init
{
    self = [self _init];
    
    if (self) {
        self.modificationDate = [NSDate date];
    }
    
    return self;
}

- (id)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
{
    self = [self _init];
    
    if (self) {
        [object setValue:self forKey:@"changeInfo"];
        
        self.modificationDate = dateFromNode(node[@"DATE"][0]);
		
        [self addPropertiesWithGedcomNodes:node[@"NOTE"]];
    }
    
    return self;
}

#pragma mark Objective-C properties

- (NSMutableArray *)mutableNoteReferences {
    return [self mutableArrayValueForKey:@"noteReferences"];
}

- (id)objectInNoteReferencesAtIndex:(NSUInteger)index {
    return [_noteReferences objectAtIndex:index];
}

- (void)insertObject:(GCNoteReferenceRelationship *)obj inNoteReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteReferenceRelationship class]]);
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_noteReferences insertObject:obj atIndex:index];
}

- (void)removeObjectFromNoteReferencesAtIndex:(NSUInteger)index {
    ((GCNoteReferenceRelationship *)_noteReferences[index]).describedObject = nil;
    [_noteReferences removeObjectAtIndex:index];
}


- (NSMutableArray *)mutableNoteEmbeddeds {
    return [self mutableArrayValueForKey:@"noteEmbeddeds"];
}

- (id)objectInNoteEmbeddedsAtIndex:(NSUInteger)index {
    return [_noteEmbeddeds objectAtIndex:index];
}

- (void)insertObject:(GCNoteEmbeddedAttribute *)obj inNoteEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteEmbeddedAttribute class]]);
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_noteEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromNoteEmbeddedsAtIndex:(NSUInteger)index {
    ((GCNoteEmbeddedAttribute *)_noteEmbeddeds[index]).describedObject = nil;
    [_noteEmbeddeds removeObjectAtIndex:index];
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

