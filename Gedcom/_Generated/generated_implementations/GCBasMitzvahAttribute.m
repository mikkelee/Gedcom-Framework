/*
 This file was autogenerated by tags.py 
 */

#import "GCBasMitzvahAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

#import "GCAddressAttribute.h"
#import "GCAgeAttribute.h"
#import "GCCauseAttribute.h"
#import "GCDateAttribute.h"
#import "GCMultimediaEmbeddedAttribute.h"
#import "GCMultimediaReferenceRelationship.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPhoneNumberAttribute.h"
#import "GCPlaceAttribute.h"
#import "GCResponsibleAgencyAttribute.h"
#import "GCSourceCitationRelationship.h"
#import "GCSourceEmbeddedAttribute.h"
#import "GCTypeDescriptionAttribute.h"

@implementation GCBasMitzvahAttribute {
	GCTypeDescriptionAttribute *_typeDescription;
	GCDateAttribute *_date;
	GCPlaceAttribute *_place;
	GCAddressAttribute *_address;
	GCPhoneNumberAttribute *_phoneNumber;
	GCAgeAttribute *_age;
	GCResponsibleAgencyAttribute *_responsibleAgency;
	GCCauseAttribute *_cause;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_multimediaReferences;
	NSMutableArray *_multimediaEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a basMitzvah.

 
 @return A new basMitzvah.
*/
+(GCBasMitzvahAttribute *)basMitzvah
{
	return [[self alloc] init];
}
/** Initializes and returns a basMitzvah.

 @param value The value as a GCValue object.
 @return A new basMitzvah.
*/
+(GCBasMitzvahAttribute *)basMitzvahWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a basMitzvah.

 @param value The value as an NSString.
 @return A new basMitzvah.
*/
+(GCBasMitzvahAttribute *)basMitzvahWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"basMitzvah"];
	
	if (self) {
		// initialize ivars, if any:
		_sourceCitations = [NSMutableArray array];
		_sourceEmbeddeds = [NSMutableArray array];
		_multimediaReferences = [NSMutableArray array];
		_multimediaEmbeddeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic eventDetails;

- (void)setTypeDescription:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setTypeDescription:_typeDescription];
	[self.context.undoManager setActionName:@"Undo typeDescription"]; //TODO
	
	if (_typeDescription) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_typeDescription = (id)obj;
}

- (GCTypeDescriptionAttribute *)typeDescription
{
	return _typeDescription;
}


- (void)setDate:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setDate:_date];
	[self.context.undoManager setActionName:@"Undo date"]; //TODO
	
	if (_date) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_date = (id)obj;
}

- (GCDateAttribute *)date
{
	return _date;
}


- (void)setPlace:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setPlace:_place];
	[self.context.undoManager setActionName:@"Undo place"]; //TODO
	
	if (_place) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_place = (id)obj;
}

- (GCPlaceAttribute *)place
{
	return _place;
}


- (void)setAddress:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setAddress:_address];
	[self.context.undoManager setActionName:@"Undo address"]; //TODO
	
	if (_address) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_address = (id)obj;
}

- (GCAddressAttribute *)address
{
	return _address;
}


- (void)setPhoneNumber:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setPhoneNumber:_phoneNumber];
	[self.context.undoManager setActionName:@"Undo phoneNumber"]; //TODO
	
	if (_phoneNumber) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_phoneNumber = (id)obj;
}

- (GCPhoneNumberAttribute *)phoneNumber
{
	return _phoneNumber;
}


- (void)setAge:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setAge:_age];
	[self.context.undoManager setActionName:@"Undo age"]; //TODO
	
	if (_age) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_age = (id)obj;
}

- (GCAgeAttribute *)age
{
	return _age;
}


- (void)setResponsibleAgency:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setResponsibleAgency:_responsibleAgency];
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


- (void)setCause:(id)obj
{
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setCause:_cause];
	[self.context.undoManager setActionName:@"Undo cause"]; //TODO
	
	if (_cause) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_cause = (id)obj;
}

- (GCCauseAttribute *)cause
{
	return _cause;
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
 
- (void)insertObject:(id)obj inSourceCitationsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSourceCitationRelationship class]]);
	
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromSourceCitationsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceCitations"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_sourceCitations insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourceCitationsAtIndex:(NSUInteger)index {
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_sourceCitations[index] inSourceCitationsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceCitations"]; //TODO
	
	[((GCObject *)_sourceCitations[index]) setValue:nil forKey:@"describedObject"];
	
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
 
- (void)insertObject:(id)obj inSourceEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSourceEmbeddedAttribute class]]);
	
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromSourceEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceEmbeddeds"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_sourceEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourceEmbeddedsAtIndex:(NSUInteger)index {
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_sourceEmbeddeds[index] inSourceEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo sourceEmbeddeds"]; //TODO
	
	[((GCObject *)_sourceEmbeddeds[index]) setValue:nil forKey:@"describedObject"];
	
    [_sourceEmbeddeds removeObjectAtIndex:index];
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
 
- (void)insertObject:(id)obj inMultimediaReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCMultimediaReferenceRelationship class]]);
	
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromMultimediaReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaReferences"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_multimediaReferences insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediaReferencesAtIndex:(NSUInteger)index {
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_multimediaReferences[index] inMultimediaReferencesAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaReferences"]; //TODO
	
	[((GCObject *)_multimediaReferences[index]) setValue:nil forKey:@"describedObject"];
	
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
 
- (void)insertObject:(id)obj inMultimediaEmbeddedsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCMultimediaEmbeddedAttribute class]]);
	
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromMultimediaEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaEmbeddeds"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_multimediaEmbeddeds insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediaEmbeddedsAtIndex:(NSUInteger)index {
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_multimediaEmbeddeds[index] inMultimediaEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo multimediaEmbeddeds"]; //TODO
	
	[((GCObject *)_multimediaEmbeddeds[index]) setValue:nil forKey:@"describedObject"];
	
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
 
- (void)insertObject:(id)obj inNoteReferencesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteReferenceRelationship class]]);
	
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:index];
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
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteReferences[index] inNoteReferencesAtIndex:index];
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
	
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:index];
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
	[(GCBasMitzvahAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[index] inNoteEmbeddedsAtIndex:index];
	[self.context.undoManager setActionName:@"Undo noteEmbeddeds"]; //TODO
	
	[((GCObject *)_noteEmbeddeds[index]) setValue:nil forKey:@"describedObject"];
	
    [_noteEmbeddeds removeObjectAtIndex:index];
}
	

@end

