/*
 This file was autogenerated by tags.py 
 */

#import "GCTitleAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCTitleAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a title.

 
 @return A new title.
*/
+(instancetype)title
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a title.

 @param value The value as a GCValue object.
 @return A new title.
*/
+(instancetype)titleWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a title.

 @param value The value as an NSString.
 @return A new title.
*/
+(instancetype)titleWithGedcomStringValue:(NSString *)value
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
