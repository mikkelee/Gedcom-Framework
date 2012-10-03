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

#import "GCObjects_generated.h"

#import "GCObject_internal.h"
#import "GCObject+GCObjectKeyValueExtensions.h"

@interface GCChangeInfoAttribute ()

@property NSDate *modificationDate;

@end

@implementation GCChangeInfoAttribute {
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

#pragma mark Initialization

- (id)init
{
	self = [super _initWithType:@"changeInfo"];
    
    if (self) {
        _noteReferences = [NSMutableArray array];
        _noteEmbeddeds = [NSMutableArray array];
    }
    
    return self;
}

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

#pragma mark Objective-C properties

@dynamic notes;

- (NSMutableArray *)mutableNoteReferences {
    return [self mutableArrayValueForKey:@"noteReferences"];
}

- (id)objectInNoteReferencesAtIndex:(NSUInteger)index {
    return [_noteReferences objectAtIndex:index];
}

- (NSArray *)noteReferencesAtIndexes:(NSIndexSet *)indexes {
    return [_noteReferences objectsAtIndexes:indexes];
}

- (void)insertObject:(GCNoteReferenceRelationship *)noteReferences inNoteReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([noteReferences isKindOfClass:[GCNoteReferenceRelationship class]]);
    [_noteReferences insertObject:noteReferences atIndex:index];
}

- (void)removeObjectFromNoteReferencesAtIndex:(NSUInteger)index {
    [_noteReferences removeObjectAtIndex:index];
}


- (NSMutableArray *)mutableNoteEmbeddeds {
    return [self mutableArrayValueForKey:@"noteEmbeddeds"];
}

- (id)objectInNoteEmbeddedsAtIndex:(NSUInteger)index {
    return [_noteEmbeddeds objectAtIndex:index];
}

- (NSArray *)noteEmbeddedsAtIndexes:(NSIndexSet *)indexes {
    return [_noteEmbeddeds objectsAtIndexes:indexes];
}

- (void)insertObject:(GCNoteEmbeddedAttribute *)noteEmbeddeds inNoteEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([noteEmbeddeds isKindOfClass:[GCNoteEmbeddedAttribute class]]);
    [noteEmbeddeds setValue:self forKey:@"describedObject"];
    [_noteEmbeddeds insertObject:noteEmbeddeds atIndex:index];
}

- (void)removeObjectFromNoteEmbeddedsAtIndex:(NSUInteger)index {
    [_noteEmbeddeds[index] setValue:nil forKey:@"describedObject"];
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

