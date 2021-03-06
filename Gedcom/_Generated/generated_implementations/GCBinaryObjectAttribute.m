/*
 This file was autogenerated by tags.py 
 */

#import "GCBinaryObjectAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCBinaryObjectAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a binaryObject.

 
 @return A new binaryObject.
*/
+(instancetype)binaryObject
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a binaryObject.

 @param value The value as a GCValue object.
 @return A new binaryObject.
*/
+(instancetype)binaryObjectWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a binaryObject.

 @param value The value as an NSString.
 @return A new binaryObject.
*/
+(instancetype)binaryObjectWithGedcomStringValue:(NSString *)value
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
