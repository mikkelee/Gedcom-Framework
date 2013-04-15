/*
 This file was autogenerated by tags.py 
 */

#import "GCDescriptiveNameAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"



@implementation GCDescriptiveNameAttribute {

}

// Methods:
/** Initializes and returns a descriptiveName.

 
 @return A new descriptiveName.
*/
+(GCDescriptiveNameAttribute *)descriptiveName
{
	return [[self alloc] init];
}
/** Initializes and returns a descriptiveName.

 @param value The value as a GCValue object.
 @return A new descriptiveName.
*/
+(GCDescriptiveNameAttribute *)descriptiveNameWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a descriptiveName.

 @param value The value as an NSString.
 @return A new descriptiveName.
*/
+(GCDescriptiveNameAttribute *)descriptiveNameWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"descriptiveName"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

