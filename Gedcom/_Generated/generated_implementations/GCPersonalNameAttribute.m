/*
 This file was autogenerated by tags.py 
 */

#import "GCPersonalNameAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCPersonalNameAttribute {
	GCNamePrefixAttribute *_namePrefix;
	GCGivenNameAttribute *_givenName;
	GCNicknameAttribute *_nickname;
	GCSurnamePrefixAttribute *_surnamePrefix;
	GCSurnameAttribute *_surname;
	GCNameSuffixAttribute *_nameSuffix;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/// @name Initializing

/** Initializes and returns a personalName.

 
 @return A new personalName.
*/
+(instancetype)personalName
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a personalName.

 @param value The value as a GCValue object.
 @return A new personalName.
*/
+(instancetype)personalNameWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a personalName.

 @param value The value as an NSString.
 @return A new personalName.
*/
+(instancetype)personalNameWithGedcomStringValue:(NSString *)value
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

- (id)namePrefix
{
	return _namePrefix;
}
	
- (void)setNamePrefix:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] setNamePrefix:_namePrefix];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_namePrefix) {
		[(id)_namePrefix setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_namePrefix = obj;
}


- (id)givenName
{
	return _givenName;
}
	
- (void)setGivenName:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] setGivenName:_givenName];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_givenName) {
		[(id)_givenName setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_givenName = obj;
}


- (id)nickname
{
	return _nickname;
}
	
- (void)setNickname:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] setNickname:_nickname];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_nickname) {
		[(id)_nickname setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_nickname = obj;
}


- (id)surnamePrefix
{
	return _surnamePrefix;
}
	
- (void)setSurnamePrefix:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] setSurnamePrefix:_surnamePrefix];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_surnamePrefix) {
		[(id)_surnamePrefix setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_surnamePrefix = obj;
}


- (id)surname
{
	return _surname;
}
	
- (void)setSurname:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] setSurname:_surname];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_surname) {
		[(id)_surname setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_surname = obj;
}


- (id)nameSuffix
{
	return _nameSuffix;
}
	
- (void)setNameSuffix:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] setNameSuffix:_nameSuffix];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_nameSuffix) {
		[(id)_nameSuffix setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_nameSuffix = obj;
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromSourceCitationsAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_sourceCitations[idx] inSourceCitationsAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromSourceEmbeddedsAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_sourceEmbeddeds[idx] inSourceEmbeddedsAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromNoteReferencesAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_noteReferences[idx] inNoteReferencesAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] removeObjectFromNoteEmbeddedsAtIndex:idx];
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
			[(GCPersonalNameAttribute *)[uM prepareWithInvocationTarget:self] insertObject:_noteEmbeddeds[idx] inNoteEmbeddedsAtIndex:idx];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	[_noteEmbeddeds[idx] setValue:nil forKey:@"describedObject"];
	
	[_noteEmbeddeds removeObjectAtIndex:idx];
}


@end
