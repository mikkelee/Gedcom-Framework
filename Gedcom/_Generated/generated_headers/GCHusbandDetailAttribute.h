/*
 This file was autogenerated by tags.py 
 */

#import "GCAttribute.h"

@class GCAgeAttribute;

/**
 
*/
@interface GCHusbandDetailAttribute : GCAttribute

// Methods:
/// @name Initializing

/** Initializes and returns a husbandDetail.

 
 @return A new husbandDetail.
*/
+(instancetype)husbandDetail;
/// @name Initializing

/** Initializes and returns a husbandDetail.

 @param value The value as a GCValue object.
 @return A new husbandDetail.
*/
+(instancetype)husbandDetailWithValue:(GCValue *)value;
/// @name Initializing

/** Initializes and returns a husbandDetail.

 @param value The value as an NSString.
 @return A new husbandDetail.
*/
+(instancetype)husbandDetailWithGedcomStringValue:(NSString *)value;

// Properties:
/// .  NB: required property.
@property (nonatomic) GCAgeAttribute *age;


@end

