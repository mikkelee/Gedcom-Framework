/*
 This file was autogenerated by tags.py 
 */

#import "GCNameSuffixAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"



@implementation GCNameSuffixAttribute {

}

// Methods:
/** Initializes and returns a nameSuffix.

 
 @return A new nameSuffix.
*/
+(GCNameSuffixAttribute *)nameSuffix
{
	return [[self alloc] init];
}
/** Initializes and returns a nameSuffix.

 @param value The value as a GCValue object.
 @return A new nameSuffix.
*/
+(GCNameSuffixAttribute *)nameSuffixWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a nameSuffix.

 @param value The value as an NSString.
 @return A new nameSuffix.
*/
+(GCNameSuffixAttribute *)nameSuffixWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"nameSuffix"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

