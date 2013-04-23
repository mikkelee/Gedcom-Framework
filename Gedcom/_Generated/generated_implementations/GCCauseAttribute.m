/*
 This file was autogenerated by tags.py 
 */

#import "GCCauseAttribute.h"

#import "GCObject_internal.h"



@implementation GCCauseAttribute {

}

// Methods:
/** Initializes and returns a cause.

 
 @return A new cause.
*/
+(instancetype)cause
{
	return [[self alloc] init];
}
/** Initializes and returns a cause.

 @param value The value as a GCValue object.
 @return A new cause.
*/
+(instancetype)causeWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a cause.

 @param value The value as an NSString.
 @return A new cause.
*/
+(instancetype)causeWithGedcomStringValue:(NSString *)value
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

