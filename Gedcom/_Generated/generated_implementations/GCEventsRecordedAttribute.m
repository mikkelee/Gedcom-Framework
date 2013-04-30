/*
 This file was autogenerated by tags.py 
 */

#import "GCEventsRecordedAttribute.h"

#import "GCDateAttribute.h"
#import "GCPlaceAttribute.h"

@implementation GCEventsRecordedAttribute {
	GCDateAttribute *_date;
	GCPlaceAttribute *_place;
}

// Methods:
/// @name Initializing

/** Initializes and returns a eventsRecorded.

 
 @return A new eventsRecorded.
*/
+(instancetype)eventsRecorded
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a eventsRecorded.

 @param value The value as a GCValue object.
 @return A new eventsRecorded.
*/
+(instancetype)eventsRecordedWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a eventsRecorded.

 @param value The value as an NSString.
 @return A new eventsRecorded.
*/
+(instancetype)eventsRecordedWithGedcomStringValue:(NSString *)value
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
@dynamic date;
@dynamic place;

@end

