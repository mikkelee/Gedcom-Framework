/*
 This file was autogenerated by tags.py 
 */

#import "GCHeaderDateAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCHeaderDateAttribute {
	GCTimeAttribute *_time;
}

// Methods:
/// @name Initializing

/** Initializes and returns a headerDate.

 
 @return A new headerDate.
*/
+(instancetype)headerDate
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a headerDate.

 @param value The value as a GCValue object.
 @return A new headerDate.
*/
+(instancetype)headerDateWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a headerDate.

 @param value The value as an NSString.
 @return A new headerDate.
*/
+(instancetype)headerDateWithGedcomStringValue:(NSString *)value
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

- (id)time
{
	return _time;
}
	
- (void)setTime:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCHeaderDateAttribute *)[uM prepareWithInvocationTarget:self] setTime:_time];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_time) {
		[(id)_time setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_time = obj;
}


@end
