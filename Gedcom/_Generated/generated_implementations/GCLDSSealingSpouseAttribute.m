/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSSealingSpouseAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCLDSSealingSpouseAttribute {
	GCLDSSealingSpouseStatusAttribute *_lDSSealingSpouseStatus;
	GCDateAttribute *_date;
	GCTempleAttribute *_temple;
	GCPlaceAttribute *_place;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/// @name Initializing

/** Initializes and returns a lDSSealingSpouse.

 
 @return A new lDSSealingSpouse.
*/
+(instancetype)lDSSealingSpouse
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a lDSSealingSpouse.

 @param value The value as a GCValue object.
 @return A new lDSSealingSpouse.
*/
+(instancetype)lDSSealingSpouseWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a lDSSealingSpouse.

 @param value The value as an NSString.
 @return A new lDSSealingSpouse.
*/
+(instancetype)lDSSealingSpouseWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (instancetype)init
{
	self = [super init];
	
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

- (id)lDSSealingSpouseStatus
{
	return _lDSSealingSpouseStatus;
}
	
- (void)setLDSSealingSpouseStatus:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] setLDSSealingSpouseStatus:_lDSSealingSpouseStatus];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_lDSSealingSpouseStatus) {
		[(id)_lDSSealingSpouseStatus setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_lDSSealingSpouseStatus = obj;
}


- (id)date
{
	return _date;
}
	
- (void)setDate:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] setDate:_date];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_date) {
		[(id)_date setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_date = obj;
}


- (id)temple
{
	return _temple;
}
	
- (void)setTemple:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] setTemple:_temple];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_temple) {
		[(id)_temple setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_temple = obj;
}


- (id)place
{
	return _place;
}
	
- (void)setPlace:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] setPlace:_place];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_place) {
		[(id)_place setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_place = obj;
}

@dynamic sources;
@synthesize sourceCitations = _sourceCitations;

@dynamic mutableSourceCitations;
- (NSMutableArray *)mutableSourceCitations
{
	return [self mutableArrayValueForKey:@"sourceCitations"];
}

- (id)objectInSourceCitationsAtIndex:(NSUInteger)idx
{
	return [_sourceCitations objectAtIndex:idx];
}

- (NSUInteger)countOfSourceCitations
{
	return [_sourceCitations count];
}

- (void)insertObject:(id)obj inSourceCitationsAtIndex:(NSUInteger)idx
{
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromSourceCitationsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	[_sourceCitations insertObject:obj atIndex:idx];
}

- (void)removeObjectFromSourceCitationsAtIndex:(NSUInteger)idx
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_sourceCitations[idx] inSourceCitationsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	[_sourceCitations[idx] setValue:nil forKey:@"describedObject"];
	
	[_sourceCitations removeObjectAtIndex:idx];
}

@synthesize sourceEmbeddeds = _sourceEmbeddeds;

@dynamic mutableSourceEmbeddeds;
- (NSMutableArray *)mutableSourceEmbeddeds
{
	return [self mutableArrayValueForKey:@"sourceEmbeddeds"];
}

- (id)objectInSourceEmbeddedsAtIndex:(NSUInteger)idx
{
	return [_sourceEmbeddeds objectAtIndex:idx];
}

- (NSUInteger)countOfSourceEmbeddeds
{
	return [_sourceEmbeddeds count];
}

- (void)insertObject:(id)obj inSourceEmbeddedsAtIndex:(NSUInteger)idx
{
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromSourceEmbeddedsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	[_sourceEmbeddeds insertObject:obj atIndex:idx];
}

- (void)removeObjectFromSourceEmbeddedsAtIndex:(NSUInteger)idx
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_sourceEmbeddeds[idx] inSourceEmbeddedsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	[_sourceEmbeddeds[idx] setValue:nil forKey:@"describedObject"];
	
	[_sourceEmbeddeds removeObjectAtIndex:idx];
}

@dynamic notes;
@synthesize noteReferences = _noteReferences;

@dynamic mutableNoteReferences;
- (NSMutableArray *)mutableNoteReferences
{
	return [self mutableArrayValueForKey:@"noteReferences"];
}

- (id)objectInNoteReferencesAtIndex:(NSUInteger)idx
{
	return [_noteReferences objectAtIndex:idx];
}

- (NSUInteger)countOfNoteReferences
{
	return [_noteReferences count];
}

- (void)insertObject:(id)obj inNoteReferencesAtIndex:(NSUInteger)idx
{
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	[_noteReferences insertObject:obj atIndex:idx];
}

- (void)removeObjectFromNoteReferencesAtIndex:(NSUInteger)idx
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_noteReferences[idx] inNoteReferencesAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	[_noteReferences[idx] setValue:nil forKey:@"describedObject"];
	
	[_noteReferences removeObjectAtIndex:idx];
}

@synthesize noteEmbeddeds = _noteEmbeddeds;

@dynamic mutableNoteEmbeddeds;
- (NSMutableArray *)mutableNoteEmbeddeds
{
	return [self mutableArrayValueForKey:@"noteEmbeddeds"];
}

- (id)objectInNoteEmbeddedsAtIndex:(NSUInteger)idx
{
	return [_noteEmbeddeds objectAtIndex:idx];
}

- (NSUInteger)countOfNoteEmbeddeds
{
	return [_noteEmbeddeds count];
}

- (void)insertObject:(id)obj inNoteEmbeddedsAtIndex:(NSUInteger)idx
{
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	[_noteEmbeddeds insertObject:obj atIndex:idx];
}

- (void)removeObjectFromNoteEmbeddedsAtIndex:(NSUInteger)idx
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCLDSSealingSpouseAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[idx] inNoteEmbeddedsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	[_noteEmbeddeds[idx] setValue:nil forKey:@"describedObject"];
	
	[_noteEmbeddeds removeObjectAtIndex:idx];
}


@end
