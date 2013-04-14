/*
 This file was autogenerated by tags.py 
 */

#import "GCCountryAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"



@implementation GCCountryAttribute {

}

// Methods:
/** Initializes and returns a country.

 
 @return A new country.
*/
+(GCCountryAttribute *)country
{
	return [[self alloc] init];
}
/** Initializes and returns a country.

 @param value The value as a GCValue object.
 @return A new country.
*/
+(GCCountryAttribute *)countryWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a country.

 @param value The value as an NSString.
 @return A new country.
*/
+(GCCountryAttribute *)countryWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"country"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:


@end

