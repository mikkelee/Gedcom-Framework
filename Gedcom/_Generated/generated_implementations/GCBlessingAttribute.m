/*
 This file was autogenerated by tags.py 
 */

#import "GCBlessingAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCBlessingAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a blessing.

 
 @return A new blessing.
*/
+(instancetype)blessing
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a blessing.

 @param value The value as a GCValue object.
 @return A new blessing.
*/
+(instancetype)blessingWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a blessing.

 @param value The value as an NSString.
 @return A new blessing.
*/
+(instancetype)blessingWithGedcomStringValue:(NSString *)value
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


@end
