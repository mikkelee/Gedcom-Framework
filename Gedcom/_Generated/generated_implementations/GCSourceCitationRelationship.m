/*
 This file was autogenerated by tags.py 
 */

#import "GCSourceCitationRelationship.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"

#import "GCDataAttribute.h"
#import "GCEventCitedAttribute.h"
#import "GCMultimediaEmbeddedAttribute.h"
#import "GCMultimediaReferenceRelationship.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPageAttribute.h"
#import "GCQualityOfDataAttribute.h"

@implementation GCSourceCitationRelationship {
	GCPageAttribute *_page;
	GCDataAttribute *_data;
	GCEventCitedAttribute *_eventCited;
	GCQualityOfDataAttribute *_qualityOfData;
	NSMutableArray *_multimediaReferences;
	NSMutableArray *_multimediaEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a sourceCitation.

 
 @return A new sourceCitation.
*/
+(GCSourceCitationRelationship *)sourceCitation
{
	return [[self alloc] init];
}
- (id)init
{
	self = [super _initWithType:@"sourceCitation"];
	
	if (self) {
		// initialize ivars, if any:
		_multimediaReferences = [NSMutableArray array];
		_multimediaEmbeddeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:

- (void)setPage:(GCProperty *)obj
{
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] setPage:_page];
	[self.context.undoManager setActionName:@"Undo page"]; //TODO
	
	if (_page) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_page = (id)obj;
}

- (GCPageAttribute *)page
{
	return _page;
}


- (void)setData:(GCProperty *)obj
{
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] setData:_data];
	[self.context.undoManager setActionName:@"Undo data"]; //TODO
	
	if (_data) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_data = (id)obj;
}

- (GCDataAttribute *)data
{
	return _data;
}


- (void)setEventCited:(GCProperty *)obj
{
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] setEventCited:_eventCited];
	[self.context.undoManager setActionName:@"Undo eventCited"]; //TODO
	
	if (_eventCited) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_eventCited = (id)obj;
}

- (GCEventCitedAttribute *)eventCited
{
	return _eventCited;
}


- (void)setQualityOfData:(GCProperty *)obj
{
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] setQualityOfData:_qualityOfData];
	[self.context.undoManager setActionName:@"Undo qualityOfData"]; //TODO
	
	if (_qualityOfData) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_qualityOfData = (id)obj;
}

- (GCQualityOfDataAttribute *)qualityOfData
{
	return _qualityOfData;
}

@dynamic multimedias;

- (NSMutableArray *)mutableMultimediaReferences {
    return [self mutableArrayValueForKey:@"multimediaReferences"];
}

- (NSUInteger)countOfMultimediaReferences {
	return [_multimediaReferences count];
}

- (id)objectInMultimediaReferencesAtIndex:(NSUInteger)index {
    return [_multimediaReferences objectAtIndex:index];
}
 
- (void)insertObject:(GCProperty *)obj inMultimediaReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCMultimediaReferenceRelationship class]]);
	
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromMultimediaReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaReferences"]; //TODO
	
	if (obj.describedObject == self) {
		return;
	}
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_multimediaReferences insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediaReferencesAtIndex:(NSUInteger)index {
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_multimediaReferences[index] inMultimediaReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaReferences"]; //TODO
	
	((GCProperty *)_multimediaReferences[index]).describedObject = nil;
	
    [_multimediaReferences removeObjectAtIndex:index];
}
	

- (NSMutableArray *)mutableMultimediaEmbeddeds {
    return [self mutableArrayValueForKey:@"multimediaEmbeddeds"];
}

- (NSUInteger)countOfMultimediaEmbeddeds {
	return [_multimediaEmbeddeds count];
}

- (id)objectInMultimediaEmbeddedsAtIndex:(NSUInteger)index {
    return [_multimediaEmbeddeds objectAtIndex:index];
}
 
- (void)insertObject:(GCProperty *)obj inMultimediaEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCMultimediaEmbeddedAttribute class]]);
	
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromMultimediaEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaEmbeddeds"]; //TODO
	
	if (obj.describedObject == self) {
		return;
	}
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_multimediaEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediaEmbeddedsAtIndex:(NSUInteger)index {
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_multimediaEmbeddeds[index] inMultimediaEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaEmbeddeds"]; //TODO
	
	((GCProperty *)_multimediaEmbeddeds[index]).describedObject = nil;
	
    [_multimediaEmbeddeds removeObjectAtIndex:index];
}
	
@dynamic notes;

- (NSMutableArray *)mutableNoteReferences {
    return [self mutableArrayValueForKey:@"noteReferences"];
}

- (NSUInteger)countOfNoteReferences {
	return [_noteReferences count];
}

- (id)objectInNoteReferencesAtIndex:(NSUInteger)index {
    return [_noteReferences objectAtIndex:index];
}
 
- (void)insertObject:(GCProperty *)obj inNoteReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteReferenceRelationship class]]);
	
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteReferences"]; //TODO
	
	if (obj.describedObject == self) {
		return;
	}
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_noteReferences insertObject:obj atIndex:index];
}

- (void)removeObjectFromNoteReferencesAtIndex:(NSUInteger)index {
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteReferences[index] inNoteReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteReferences"]; //TODO
	
	((GCProperty *)_noteReferences[index]).describedObject = nil;
	
    [_noteReferences removeObjectAtIndex:index];
}
	

- (NSMutableArray *)mutableNoteEmbeddeds {
    return [self mutableArrayValueForKey:@"noteEmbeddeds"];
}

- (NSUInteger)countOfNoteEmbeddeds {
	return [_noteEmbeddeds count];
}

- (id)objectInNoteEmbeddedsAtIndex:(NSUInteger)index {
    return [_noteEmbeddeds objectAtIndex:index];
}
 
- (void)insertObject:(GCProperty *)obj inNoteEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteEmbeddedAttribute class]]);
	
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	if (obj.describedObject == self) {
		return;
	}
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_noteEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromNoteEmbeddedsAtIndex:(NSUInteger)index {
	[(GCSourceCitationRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[index] inNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	((GCProperty *)_noteEmbeddeds[index]).describedObject = nil;
	
    [_noteEmbeddeds removeObjectAtIndex:index];
}
	

@end

