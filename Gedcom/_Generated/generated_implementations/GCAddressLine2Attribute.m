/*
 This file was autogenerated by tags.py 
 */

#import "GCAddressLine2Attribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCAddressLine2Attribute {

}

// Methods:
/** Initializes and returns a addressLine2.

 
 @return A new addressLine2.
*/
+(GCAddressLine2Attribute *)addressLine2
{
	return [[self alloc] init];
}
/** Initializes and returns a addressLine2.

 @param value The value as a GCValue object.
 @return A new addressLine2.
*/
+(GCAddressLine2Attribute *)addressLine2WithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a addressLine2.

 @param value The value as an NSString.
 @return A new addressLine2.
*/
+(GCAddressLine2Attribute *)addressLine2WithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"addressLine2"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

