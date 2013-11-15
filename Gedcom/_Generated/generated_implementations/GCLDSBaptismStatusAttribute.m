/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSBaptismStatusAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCLDSBaptismStatusAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a lDSBaptismStatus.

 
 @return A new lDSBaptismStatus.
*/
+(instancetype)lDSBaptismStatus
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a lDSBaptismStatus.

 @param value The value as a GCValue object.
 @return A new lDSBaptismStatus.
*/
+(instancetype)lDSBaptismStatusWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a lDSBaptismStatus.

 @param value The value as an NSString.
 @return A new lDSBaptismStatus.
*/
+(instancetype)lDSBaptismStatusWithGedcomStringValue:(NSString *)value
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
