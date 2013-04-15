/*
 This file was autogenerated by tags.py 
 */

#import "GCTempleAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCTempleAttribute {

}

// Methods:
/** Initializes and returns a temple.

 
 @return A new temple.
*/
+(GCTempleAttribute *)temple
{
	return [[self alloc] init];
}
/** Initializes and returns a temple.

 @param value The value as a GCValue object.
 @return A new temple.
*/
+(GCTempleAttribute *)templeWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a temple.

 @param value The value as an NSString.
 @return A new temple.
*/
+(GCTempleAttribute *)templeWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"temple"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end
