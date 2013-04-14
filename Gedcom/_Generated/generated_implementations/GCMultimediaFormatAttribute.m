/*
 This file was autogenerated by tags.py 
 */

#import "GCMultimediaFormatAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"



@implementation GCMultimediaFormatAttribute {

}

// Methods:
/** Initializes and returns a multimediaFormat.

 
 @return A new multimediaFormat.
*/
+(GCMultimediaFormatAttribute *)multimediaFormat
{
	return [[self alloc] init];
}
/** Initializes and returns a multimediaFormat.

 @param value The value as a GCValue object.
 @return A new multimediaFormat.
*/
+(GCMultimediaFormatAttribute *)multimediaFormatWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a multimediaFormat.

 @param value The value as an NSString.
 @return A new multimediaFormat.
*/
+(GCMultimediaFormatAttribute *)multimediaFormatWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"multimediaFormat"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

