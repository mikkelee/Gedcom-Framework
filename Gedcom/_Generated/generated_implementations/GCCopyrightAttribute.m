/*
 This file was autogenerated by tags.py 
 */

#import "GCCopyrightAttribute.h"

#import "GCObject_internal.h"



@implementation GCCopyrightAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a copyright.

 
 @return A new copyright.
*/
+(instancetype)copyright
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a copyright.

 @param value The value as a GCValue object.
 @return A new copyright.
*/
+(instancetype)copyrightWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a copyright.

 @param value The value as an NSString.
 @return A new copyright.
*/
+(instancetype)copyrightWithGedcomStringValue:(NSString *)value
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

