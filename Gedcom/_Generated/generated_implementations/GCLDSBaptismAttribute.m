/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSBaptismAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"

#import "GCDateAttribute.h"
#import "GCLDSBaptismStatusAttribute.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPlaceAttribute.h"
#import "GCSourceCitationRelationship.h"
#import "GCSourceEmbeddedAttribute.h"
#import "GCTempleAttribute.h"

@implementation GCLDSBaptismAttribute {
	GCLDSBaptismStatusAttribute *_lDSBaptismStatus;
	GCDateAttribute *_date;
	GCTempleAttribute *_temple;
	GCPlaceAttribute *_place;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a lDSBaptism.

 
 @return A new lDSBaptism.
*/
+(GCLDSBaptismAttribute *)lDSBaptism
{
	return [[self alloc] init];
}
/** Initializes and returns a lDSBaptism.

 @param value The value as a GCValue object.
 @return A new lDSBaptism.
*/
+(GCLDSBaptismAttribute *)lDSBaptismWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a lDSBaptism.

 @param value The value as an NSString.
 @return A new lDSBaptism.
*/
+(GCLDSBaptismAttribute *)lDSBaptismWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"lDSBaptism"];
	
	if (self) {
		// initialize ivars, if any:
		_sourceCitations = [NSMutableArray array];
		_sourceEmbeddeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:

- (void)setLDSBaptismStatus:(GCProperty *)obj
{
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setLDSBaptismStatus:_lDSBaptismStatus];
	[self.context.undoManager setActionName:@"Undo lDSBaptismStatus"]; //TODO
	
	if (_lDSBaptismStatus) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_lDSBaptismStatus = (id)obj;
}

- (GCLDSBaptismStatusAttribute *)lDSBaptismStatus
{
	return _lDSBaptismStatus;
}


- (void)setDate:(GCProperty *)obj
{
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setDate:_date];
	[self.context.undoManager setActionName:@"Undo date"]; //TODO
	
	if (_date) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_date = (id)obj;
}

- (GCDateAttribute *)date
{
	return _date;
}


- (void)setTemple:(GCProperty *)obj
{
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setTemple:_temple];
	[self.context.undoManager setActionName:@"Undo temple"]; //TODO
	
	if (_temple) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_temple = (id)obj;
}

- (GCTempleAttribute *)temple
{
	return _temple;
}


- (void)setPlace:(GCProperty *)obj
{
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setPlace:_place];
	[self.context.undoManager setActionName:@"Undo place"]; //TODO
	
	if (_place) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_place = (id)obj;
}

- (GCPlaceAttribute *)place
{
	return _place;
}

@dynamic sources;

- (NSMutableArray *)mutableSourceCitations {
    return [self mutableArrayValueForKey:@"sourceCitations"];
}

- (NSUInteger)countOfSourceCitations {
	return [_sourceCitations count];
}

- (id)objectInSourceCitationsAtIndex:(NSUInteger)index {
    return [_sourceCitations objectAtIndex:index];
}
 
- (void)insertObject:(GCProperty *)obj inSourceCitationsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSourceCitationRelationship class]]);
	
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromSourceCitationsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceCitations"]; //TODO
	
	if (obj.describedObject == self) {
		return;
	}
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_sourceCitations insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourceCitationsAtIndex:(NSUInteger)index {
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_sourceCitations[index] inSourceCitationsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceCitations"]; //TODO
	
	((GCProperty *)_sourceCitations[index]).describedObject = nil;
	
    [_sourceCitations removeObjectAtIndex:index];
}
	

- (NSMutableArray *)mutableSourceEmbeddeds {
    return [self mutableArrayValueForKey:@"sourceEmbeddeds"];
}

- (NSUInteger)countOfSourceEmbeddeds {
	return [_sourceEmbeddeds count];
}

- (id)objectInSourceEmbeddedsAtIndex:(NSUInteger)index {
    return [_sourceEmbeddeds objectAtIndex:index];
}
 
- (void)insertObject:(GCProperty *)obj inSourceEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSourceEmbeddedAttribute class]]);
	
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromSourceEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceEmbeddeds"]; //TODO
	
	if (obj.describedObject == self) {
		return;
	}
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	obj.describedObject = self;
    [_sourceEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourceEmbeddedsAtIndex:(NSUInteger)index {
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_sourceEmbeddeds[index] inSourceEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceEmbeddeds"]; //TODO
	
	((GCProperty *)_sourceEmbeddeds[index]).describedObject = nil;
	
    [_sourceEmbeddeds removeObjectAtIndex:index];
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
	
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:index];
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
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteReferences[index] inNoteReferencesAtIndex:index];
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
	
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:index];
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
	[(GCLDSBaptismAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[index] inNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	((GCProperty *)_noteEmbeddeds[index]).describedObject = nil;
	
    [_noteEmbeddeds removeObjectAtIndex:index];
}
	

@end

