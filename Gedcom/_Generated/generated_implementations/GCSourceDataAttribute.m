/*
 This file was autogenerated by tags.py 
 */

#import "GCSourceDataAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

#import "GCEventsRecordedAttribute.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCResponsibleAgencyAttribute.h"

@implementation GCSourceDataAttribute {
	NSMutableArray *_eventsRecordeds;
	GCResponsibleAgencyAttribute *_responsibleAgency;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a sourceData.

 
 @return A new sourceData.
*/
+(GCSourceDataAttribute *)sourceData
{
	return [[self alloc] init];
}
/** Initializes and returns a sourceData.

 @param value The value as a GCValue object.
 @return A new sourceData.
*/
+(GCSourceDataAttribute *)sourceDataWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a sourceData.

 @param value The value as an NSString.
 @return A new sourceData.
*/
+(GCSourceDataAttribute *)sourceDataWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"sourceData"];
	
	if (self) {
		// initialize ivars, if any:
		_eventsRecordeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:

- (NSMutableArray *)mutableEventsRecordeds {
    return [self mutableArrayValueForKey:@"eventsRecordeds"];
}

- (NSUInteger)countOfEventsRecordeds {
	return [_eventsRecordeds count];
}

- (id)objectInEventsRecordedsAtIndex:(NSUInteger)index {
    return [_eventsRecordeds objectAtIndex:index];
}
 
- (void)insertObject:(id)obj inEventsRecordedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCEventsRecordedAttribute class]]);
	
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromEventsRecordedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo eventsRecordeds"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_eventsRecordeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromEventsRecordedsAtIndex:(NSUInteger)index {
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_eventsRecordeds[index] inEventsRecordedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo eventsRecordeds"]; //TODO
	
	[((GCObject *)_eventsRecordeds[index]) setValue:nil forKey:@"describedObject"];
	
    [_eventsRecordeds removeObjectAtIndex:index];
}
	

- (void)setResponsibleAgency:(id)obj
{
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setResponsibleAgency:_responsibleAgency];
	[self.context.undoManager setActionName:@"Undo responsibleAgency"]; //TODO
	
	if (_responsibleAgency) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_responsibleAgency = (id)obj;
}

- (GCResponsibleAgencyAttribute *)responsibleAgency
{
	return _responsibleAgency;
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
 
- (void)insertObject:(id)obj inNoteReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteReferenceRelationship class]]);
	
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteReferences"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_noteReferences insertObject:obj atIndex:index];
}

- (void)removeObjectFromNoteReferencesAtIndex:(NSUInteger)index {
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteReferences[index] inNoteReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteReferences"]; //TODO
	
	[((GCObject *)_noteReferences[index]) setValue:nil forKey:@"describedObject"];
	
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
 
- (void)insertObject:(id)obj inNoteEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteEmbeddedAttribute class]]);
	
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_noteEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromNoteEmbeddedsAtIndex:(NSUInteger)index {
	[(GCSourceDataAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[index] inNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	[((GCObject *)_noteEmbeddeds[index]) setValue:nil forKey:@"describedObject"];
	
    [_noteEmbeddeds removeObjectAtIndex:index];
}
	

@end

