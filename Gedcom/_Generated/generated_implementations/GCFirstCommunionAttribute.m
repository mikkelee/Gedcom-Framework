/*
 This file was autogenerated by tags.py 
 */

#import "GCFirstCommunionAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCFirstCommunionAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a firstCommunion.

 
 @return A new firstCommunion.
*/
+(instancetype)firstCommunion
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a firstCommunion.

 @param value The value as a GCValue object.
 @return A new firstCommunion.
*/
+(instancetype)firstCommunionWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a firstCommunion.

 @param value The value as an NSString.
 @return A new firstCommunion.
*/
+(instancetype)firstCommunionWithGedcomStringValue:(NSString *)value
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
