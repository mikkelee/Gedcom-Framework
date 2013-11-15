/*
 This file was autogenerated by tags.py 
 */

#import "GCReligionAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCReligionAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a religion.

 
 @return A new religion.
*/
+(instancetype)religion
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a religion.

 @param value The value as a GCValue object.
 @return A new religion.
*/
+(instancetype)religionWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a religion.

 @param value The value as an NSString.
 @return A new religion.
*/
+(instancetype)religionWithGedcomStringValue:(NSString *)value
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
