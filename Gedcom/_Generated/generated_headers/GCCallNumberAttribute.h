/*
 This file was autogenerated by tags.py 
 */

#import "GCAttribute.h"

@class GCMediaTypeAttribute;

/**
 
*/
@interface GCCallNumberAttribute : GCAttribute

// Methods:
/** Initializes and returns a callNumber.

 
 @return A new callNumber.
*/
+(instancetype)callNumber;
/** Initializes and returns a callNumber.

 @param value The value as a GCValue object.
 @return A new callNumber.
*/
+(instancetype)callNumberWithValue:(GCValue *)value;
/** Initializes and returns a callNumber.

 @param value The value as an NSString.
 @return A new callNumber.
*/
+(instancetype)callNumberWithGedcomStringValue:(NSString *)value;

// Properties:
/// . 
@property (nonatomic) GCMediaTypeAttribute *mediaType;


@end

