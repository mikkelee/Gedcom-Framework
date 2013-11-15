/*
 This file was autogenerated by tags.py 
 */

#import "GCCallNumberAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCCallNumberAttribute {
	GCMediaTypeAttribute *_mediaType;
}

// Methods:
/// @name Initializing

/** Initializes and returns a callNumber.

 
 @return A new callNumber.
*/
+(instancetype)callNumber
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a callNumber.

 @param value The value as a GCValue object.
 @return A new callNumber.
*/
+(instancetype)callNumberWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a callNumber.

 @param value The value as an NSString.
 @return A new callNumber.
*/
+(instancetype)callNumberWithGedcomStringValue:(NSString *)value
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

- (id)mediaType
{
	return _mediaType;
}
	
- (void)setMediaType:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCCallNumberAttribute *)[uM prepareWithInvocationTarget:self] setMediaType:_mediaType];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_mediaType) {
		[(id)_mediaType setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_mediaType = obj;
}


@end
