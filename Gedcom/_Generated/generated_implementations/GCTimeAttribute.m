/*
 This file was autogenerated by tags.py 
 */

#import "GCTimeAttribute.h"

#import "GCObject_internal.h"



@implementation GCTimeAttribute {

}

// Methods:
/** Initializes and returns a time.

 
 @return A new time.
*/
+(instancetype)time
{
	return [[self alloc] init];
}
/** Initializes and returns a time.

 @param value The value as a GCValue object.
 @return A new time.
*/
+(instancetype)timeWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a time.

 @param value The value as an NSString.
 @return A new time.
*/
+(instancetype)timeWithGedcomStringValue:(NSString *)value
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

