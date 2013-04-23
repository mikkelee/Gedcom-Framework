/*
 This file was autogenerated by tags.py 
 */

#import "GCTypeDescriptionAttribute.h"

#import "GCObject_internal.h"



@implementation GCTypeDescriptionAttribute {

}

// Methods:
/** Initializes and returns a typeDescription.

 
 @return A new typeDescription.
*/
+(instancetype)typeDescription
{
	return [[self alloc] init];
}
/** Initializes and returns a typeDescription.

 @param value The value as a GCValue object.
 @return A new typeDescription.
*/
+(instancetype)typeDescriptionWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a typeDescription.

 @param value The value as an NSString.
 @return A new typeDescription.
*/
+(instancetype)typeDescriptionWithGedcomStringValue:(NSString *)value
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

