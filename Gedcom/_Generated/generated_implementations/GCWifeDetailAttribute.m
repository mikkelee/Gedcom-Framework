/*
 This file was autogenerated by tags.py 
 */

#import "GCWifeDetailAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCWifeDetailAttribute {
	GCAgeAttribute *_age;
}

// Methods:
/// @name Initializing

/** Initializes and returns a wifeDetail.

 
 @return A new wifeDetail.
*/
+(instancetype)wifeDetail
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a wifeDetail.

 @param value The value as a GCValue object.
 @return A new wifeDetail.
*/
+(instancetype)wifeDetailWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a wifeDetail.

 @param value The value as an NSString.
 @return A new wifeDetail.
*/
+(instancetype)wifeDetailWithGedcomStringValue:(NSString *)value
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

- (id)age
{
	return _age;
}
	
- (void)setAge:(id)obj
{
	if (!_isBuildingFromGedcom) {
		NSUndoManager *uM = [self valueForKey:@"undoManager"];
		@synchronized (uM) {
			[uM beginUndoGrouping];
			[(GCWifeDetailAttribute *)[uM prepareWithInvocationTarget:self] setAge:_age];
			[uM setActionName:[NSString stringWithFormat:GCLocalizedString(@"Undo %@", @"Misc"), self.localizedType]];
			[uM endUndoGrouping];
		}
	}
	
	if (_age) {
		[(id)_age setValue:nil forKey:@"describedObject"];
	}
	
	[[obj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:obj];
	
	[obj setValue:self forKey:@"describedObject"];
	
	_age = obj;
}


@end
