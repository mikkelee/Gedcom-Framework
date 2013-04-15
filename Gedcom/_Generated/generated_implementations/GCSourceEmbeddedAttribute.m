/*
 This file was autogenerated by tags.py 
 */

#import "GCSourceEmbeddedAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCTextAttribute.h"

@implementation GCSourceEmbeddedAttribute {
	NSMutableArray *_texts;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a sourceEmbedded.

 
 @return A new sourceEmbedded.
*/
+(GCSourceEmbeddedAttribute *)sourceEmbedded
{
	return [[self alloc] init];
}
/** Initializes and returns a sourceEmbedded.

 @param value The value as a GCValue object.
 @return A new sourceEmbedded.
*/
+(GCSourceEmbeddedAttribute *)sourceEmbeddedWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a sourceEmbedded.

 @param value The value as an NSString.
 @return A new sourceEmbedded.
*/
+(GCSourceEmbeddedAttribute *)sourceEmbeddedWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"sourceEmbedded"];
	
	if (self) {
		// initialize ivars, if any:
		_texts = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:

- (NSMutableArray *)mutableTexts {
    return [self mutableArrayValueForKey:@"texts"];
}

- (NSUInteger)countOfTexts {
	return [_texts count];
}

- (id)objectInTextsAtIndex:(NSUInteger)index {
    return [_texts objectAtIndex:index];
}
 
- (void)insertObject:(id)obj inTextsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCTextAttribute class]]);
	
	[(GCSourceEmbeddedAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromTextsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo texts"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_texts insertObject:obj atIndex:index];
}

- (void)removeObjectFromTextsAtIndex:(NSUInteger)index {
	[(GCSourceEmbeddedAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_texts[index] inTextsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo texts"]; //TODO
	
	[((GCObject *)_texts[index]) setValue:nil forKey:@"describedObject"];
	
    [_texts removeObjectAtIndex:index];
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
	
	[(GCSourceEmbeddedAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:index];
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
	[(GCSourceEmbeddedAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteReferences[index] inNoteReferencesAtIndex:index];
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
	
	[(GCSourceEmbeddedAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:index];
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
	[(GCSourceEmbeddedAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[index] inNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	[((GCObject *)_noteEmbeddeds[index]) setValue:nil forKey:@"describedObject"];
	
    [_noteEmbeddeds removeObjectAtIndex:index];
}
	

@end

