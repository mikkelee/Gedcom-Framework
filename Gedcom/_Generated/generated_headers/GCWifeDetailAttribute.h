/*
 This file was autogenerated by tags.py 
 */

#import "GCAttribute.h"

@class GCAgeAttribute;

/**
 
*/
@interface GCWifeDetailAttribute : GCAttribute

// Methods:
/** Initializes and returns a wifeDetail.

 
 @return A new wifeDetail.
*/
+(instancetype)wifeDetail;
/** Initializes and returns a wifeDetail.

 @param value The value as a GCValue object.
 @return A new wifeDetail.
*/
+(instancetype)wifeDetailWithValue:(GCValue *)value;
/** Initializes and returns a wifeDetail.

 @param value The value as an NSString.
 @return A new wifeDetail.
*/
+(instancetype)wifeDetailWithGedcomStringValue:(NSString *)value;

// Properties:
/// .  NB: required property.
@property (nonatomic) GCAgeAttribute *age;


@end

