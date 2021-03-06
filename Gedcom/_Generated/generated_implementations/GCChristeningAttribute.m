/*
 This file was autogenerated by tags.py 
 */

#import "GCChristeningAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCChristeningAttribute {
	GCChildInFamilyRelationship *_childInFamily;
}

// Methods:
/// @name Initializing

/** Initializes and returns a christening.

 
 @return A new christening.
*/
+(instancetype)christening
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a christening.

 @param value The value as a GCValue object.
 @return A new christening.
*/
+(instancetype)christeningWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a christening.

 @param value The value as an NSString.
 @return A new christening.
*/
+(instancetype)christeningWithGedcomStringValue:(NSString *)value
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

- (id)childInFamily
{
	return _childInFamily;
}
	
- (void)setChildInFamily:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCChristeningAttribute *)[uM prepareWithInvocationTarget:self] setChildInFamily:_childInFamily];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_childInFamily) {
		[(id)_childInFamily setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_childInFamily = obj;
}


@end
