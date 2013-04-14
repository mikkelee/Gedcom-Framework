/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSConfirmationStatusAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"



@implementation GCLDSConfirmationStatusAttribute {

}

// Methods:
/** Initializes and returns a lDSConfirmationStatus.

 
 @return A new lDSConfirmationStatus.
*/
+(GCLDSConfirmationStatusAttribute *)lDSConfirmationStatus
{
	return [[self alloc] init];
}
/** Initializes and returns a lDSConfirmationStatus.

 @param value The value as a GCValue object.
 @return A new lDSConfirmationStatus.
*/
+(GCLDSConfirmationStatusAttribute *)lDSConfirmationStatusWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a lDSConfirmationStatus.

 @param value The value as an NSString.
 @return A new lDSConfirmationStatus.
*/
+(GCLDSConfirmationStatusAttribute *)lDSConfirmationStatusWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"lDSConfirmationStatus"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

