/*
 This file was autogenerated by tags.py 
 */

#import "GCEventDetailAttribute.h"

@class GCAddressLine1Attribute;
@class GCAddressLine2Attribute;
@class GCCityAttribute;
@class GCCountryAttribute;
@class GCPostalCodeAttribute;
@class GCStateAttribute;

/**
 
*/
@interface GCAddressAttribute : GCEventDetailAttribute

// Methods:
/** Initializes and returns a address.

 
 @return A new address.
*/
+(instancetype)address;
/** Initializes and returns a address.

 @param value The value as a GCValue object.
 @return A new address.
*/
+(instancetype)addressWithValue:(GCValue *)value;
/** Initializes and returns a address.

 @param value The value as an NSString.
 @return A new address.
*/
+(instancetype)addressWithGedcomStringValue:(NSString *)value;

// Properties:
/// . 
@property (nonatomic) GCAddressLine1Attribute *addressLine1;

/// . 
@property (nonatomic) GCAddressLine2Attribute *addressLine2;

/// . 
@property (nonatomic) GCCityAttribute *city;

/// . 
@property (nonatomic) GCStateAttribute *state;

/// . 
@property (nonatomic) GCPostalCodeAttribute *postalCode;

/// . 
@property (nonatomic) GCCountryAttribute *country;


@end

