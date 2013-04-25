/*
 This file was autogenerated by tags.py 
 */

#import "GCMultimediaFormatAttribute.h"

#import "GCObject_internal.h"



@implementation GCMultimediaFormatAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a multimediaFormat.

 
 @return A new multimediaFormat.
*/
+(instancetype)multimediaFormat
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a multimediaFormat.

 @param value The value as a GCValue object.
 @return A new multimediaFormat.
*/
+(instancetype)multimediaFormatWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a multimediaFormat.

 @param value The value as an NSString.
 @return A new multimediaFormat.
*/
+(instancetype)multimediaFormatWithGedcomStringValue:(NSString *)value
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

