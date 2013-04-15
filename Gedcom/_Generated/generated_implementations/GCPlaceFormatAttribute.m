/*
 This file was autogenerated by tags.py 
 */

#import "GCPlaceFormatAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCPlaceFormatAttribute {

}

// Methods:
/** Initializes and returns a placeFormat.

 
 @return A new placeFormat.
*/
+(GCPlaceFormatAttribute *)placeFormat
{
	return [[self alloc] init];
}
/** Initializes and returns a placeFormat.

 @param value The value as a GCValue object.
 @return A new placeFormat.
*/
+(GCPlaceFormatAttribute *)placeFormatWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a placeFormat.

 @param value The value as an NSString.
 @return A new placeFormat.
*/
+(GCPlaceFormatAttribute *)placeFormatWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"placeFormat"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

