/*
 This file was autogenerated by tags.py 
 */

#import "GCAttribute.h"

@class GCCorporationAttribute;
@class GCDescriptiveNameAttribute;
@class GCHeaderSourceDataAttribute;
@class GCVersionAttribute;

/**
 
*/
@interface GCHeaderSourceAttribute : GCAttribute

// Methods:
/// @name Initializing

/** Initializes and returns a headerSource.

 
 @return A new headerSource.
*/
+(instancetype)headerSource;
/// @name Initializing

/** Initializes and returns a headerSource.

 @param value The value as a GCValue object.
 @return A new headerSource.
*/
+(instancetype)headerSourceWithValue:(GCValue *)value;
/// @name Initializing

/** Initializes and returns a headerSource.

 @param value The value as an NSString.
 @return A new headerSource.
*/
+(instancetype)headerSourceWithGedcomStringValue:(NSString *)value;

// Properties:
/// . 
@property (nonatomic) GCVersionAttribute *version;

/// . 
@property (nonatomic) GCDescriptiveNameAttribute *descriptiveName;

/// . 
@property (nonatomic) GCCorporationAttribute *corporation;

/// . 
@property (nonatomic) GCHeaderSourceDataAttribute *headerSourceData;


@end

