/*
 This file was autogenerated by tags.py 
 */

#import "GCLanguageAttribute.h"

#import "GCObject_internal.h"



@implementation GCLanguageAttribute {

}

// Methods:
/** Initializes and returns a language.

 
 @return A new language.
*/
+(instancetype)language
{
	return [[self alloc] init];
}
/** Initializes and returns a language.

 @param value The value as a GCValue object.
 @return A new language.
*/
+(instancetype)languageWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a language.

 @param value The value as an NSString.
 @return A new language.
*/
+(instancetype)languageWithGedcomStringValue:(NSString *)value
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

