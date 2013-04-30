/*
 This file was autogenerated by tags.py 
 */

#import "GCDescriptiveNameAttribute.h"



@implementation GCDescriptiveNameAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a descriptiveName.

 
 @return A new descriptiveName.
*/
+(instancetype)descriptiveName
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a descriptiveName.

 @param value The value as a GCValue object.
 @return A new descriptiveName.
*/
+(instancetype)descriptiveNameWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a descriptiveName.

 @param value The value as an NSString.
 @return A new descriptiveName.
*/
+(instancetype)descriptiveNameWithGedcomStringValue:(NSString *)value
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

