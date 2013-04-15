/*
 This file was autogenerated by tags.py 
 */

#import "GCPhoneNumberAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCPhoneNumberAttribute {

}

// Methods:
/** Initializes and returns a phoneNumber.

 
 @return A new phoneNumber.
*/
+(GCPhoneNumberAttribute *)phoneNumber
{
	return [[self alloc] init];
}
/** Initializes and returns a phoneNumber.

 @param value The value as a GCValue object.
 @return A new phoneNumber.
*/
+(GCPhoneNumberAttribute *)phoneNumberWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a phoneNumber.

 @param value The value as an NSString.
 @return A new phoneNumber.
*/
+(GCPhoneNumberAttribute *)phoneNumberWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"phoneNumber"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

