/*
 This file was autogenerated by tags.py 
 */

#import "GCOrdinanceFlagAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"



@implementation GCOrdinanceFlagAttribute {

}

// Methods:
/** Initializes and returns a ordinanceFlag.

 
 @return A new ordinanceFlag.
*/
+(GCOrdinanceFlagAttribute *)ordinanceFlag
{
	return [[self alloc] init];
}
/** Initializes and returns a ordinanceFlag.

 @param value The value as a GCValue object.
 @return A new ordinanceFlag.
*/
+(GCOrdinanceFlagAttribute *)ordinanceFlagWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a ordinanceFlag.

 @param value The value as an NSString.
 @return A new ordinanceFlag.
*/
+(GCOrdinanceFlagAttribute *)ordinanceFlagWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"ordinanceFlag"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

