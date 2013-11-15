/*
 This file was autogenerated by tags.py 
 */

#import "GCNoteEmbeddedAttribute.h"

#import "GCTagAccessAdditions.h"
#import "GCObject_internal.h"
#import "Gedcom_internal.h"

@implementation GCNoteEmbeddedAttribute {

}

// Methods:
/// @name Initializing

/** Initializes and returns a noteEmbedded.

 
 @return A new noteEmbedded.
*/
+(instancetype)noteEmbedded
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a noteEmbedded.

 @param value The value as a GCValue object.
 @return A new noteEmbedded.
*/
+(instancetype)noteEmbeddedWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a noteEmbedded.

 @param value The value as an NSString.
 @return A new noteEmbedded.
*/
+(instancetype)noteEmbeddedWithGedcomStringValue:(NSString *)value
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
