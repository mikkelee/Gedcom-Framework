/*
 This file was autogenerated by tags.py 
 */

#import "GCSurnamePrefixAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCSurnamePrefixAttribute {

}

// Methods:
/** Initializes and returns a surnamePrefix.

 
 @return A new surnamePrefix.
*/
+(GCSurnamePrefixAttribute *)surnamePrefix
{
	return [[self alloc] init];
}
/** Initializes and returns a surnamePrefix.

 @param value The value as a GCValue object.
 @return A new surnamePrefix.
*/
+(GCSurnamePrefixAttribute *)surnamePrefixWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a surnamePrefix.

 @param value The value as an NSString.
 @return A new surnamePrefix.
*/
+(GCSurnamePrefixAttribute *)surnamePrefixWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"surnamePrefix"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end
