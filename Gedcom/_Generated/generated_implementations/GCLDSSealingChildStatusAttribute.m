/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSSealingChildStatusAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCLDSSealingChildStatusAttribute {

}

// Methods:
/** Initializes and returns a lDSSealingChildStatus.

 
 @return A new lDSSealingChildStatus.
*/
+(GCLDSSealingChildStatusAttribute *)lDSSealingChildStatus
{
	return [[self alloc] init];
}
/** Initializes and returns a lDSSealingChildStatus.

 @param value The value as a GCValue object.
 @return A new lDSSealingChildStatus.
*/
+(GCLDSSealingChildStatusAttribute *)lDSSealingChildStatusWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a lDSSealingChildStatus.

 @param value The value as an NSString.
 @return A new lDSSealingChildStatus.
*/
+(GCLDSSealingChildStatusAttribute *)lDSSealingChildStatusWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"lDSSealingChildStatus"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

