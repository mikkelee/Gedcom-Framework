/*
 This file was autogenerated by tags.py 
 */

#import "GCAttribute.h"

@class GCPlaceFormatAttribute;

/**
 
*/
@interface GCPlaceFormatSpecifierAttribute : GCAttribute

// Methods:
/** Initializes and returns a placeFormatSpecifier.

 
 @return A new placeFormatSpecifier.
*/
+(GCPlaceFormatSpecifierAttribute *)placeFormatSpecifier;
/** Initializes and returns a placeFormatSpecifier.

 @param value The value as a GCValue object.
 @return A new placeFormatSpecifier.
*/
+(GCPlaceFormatSpecifierAttribute *)placeFormatSpecifierWithValue:(GCValue *)value;
/** Initializes and returns a placeFormatSpecifier.

 @param value The value as an NSString.
 @return A new placeFormatSpecifier.
*/
+(GCPlaceFormatSpecifierAttribute *)placeFormatSpecifierWithGedcomStringValue:(NSString *)value;

// Properties:
/// .  NB: required property.
@property (nonatomic) GCPlaceFormatAttribute *placeFormat;


@end
