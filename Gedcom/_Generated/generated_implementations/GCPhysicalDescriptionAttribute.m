/*
 This file was autogenerated by tags.py 
 */

#import "GCPhysicalDescriptionAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCPhysicalDescriptionAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a physicalDescription.

 
 @return A new physicalDescription.
*/
+(instancetype)physicalDescription
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a physicalDescription.

 @param value The value as a GCValue object.
 @return A new physicalDescription.
*/
+(instancetype)physicalDescriptionWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a physicalDescription.

 @param value The value as an NSString.
 @return A new physicalDescription.
*/
+(instancetype)physicalDescriptionWithGedcomStringValue:(NSString *)value
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
