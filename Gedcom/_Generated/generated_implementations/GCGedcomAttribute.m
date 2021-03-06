/*
 This file was autogenerated by tags.py 
 */

#import "GCGedcomAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCGedcomAttribute {
	GCVersionAttribute *_version;
	GCGedcomFormatAttribute *_gedcomFormat;
}

// Methods:
/// @name Initializing

/** Initializes and returns a gedcom.

 
 @return A new gedcom.
*/
+(instancetype)gedcom
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a gedcom.

 @param value The value as a GCValue object.
 @return A new gedcom.
*/
+(instancetype)gedcomWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a gedcom.

 @param value The value as an NSString.
 @return A new gedcom.
*/
+(instancetype)gedcomWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:

- (id)version
{
	return _version;
}
	
- (void)setVersion:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCGedcomAttribute *)[uM prepareWithInvocationTarget:self] setVersion:_version];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_version) {
		[(id)_version setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_version = obj;
}


- (id)gedcomFormat
{
	return _gedcomFormat;
}
	
- (void)setGedcomFormat:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCGedcomAttribute *)[uM prepareWithInvocationTarget:self] setGedcomFormat:_gedcomFormat];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_gedcomFormat) {
		[(id)_gedcomFormat setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_gedcomFormat = obj;
}


@end
