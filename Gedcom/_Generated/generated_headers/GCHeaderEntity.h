/*
 This file was autogenerated by tags.py 
 */

#import "GCEntity.h"

@class GCCharacterSetAttribute;
@class GCCopyrightAttribute;
@class GCDestinationAttribute;
@class GCFileAttribute;
@class GCGedcomAttribute;
@class GCHeaderDateAttribute;
@class GCHeaderSourceAttribute;
@class GCLanguageAttribute;
@class GCNoteEmbeddedAttribute;
@class GCPlaceFormatSpecifierAttribute;
@class GCSubmissionReferenceRelationship;
@class GCSubmitterReferenceRelationship;

/**
 The header structure provides information about the entire transmission. The headerSource identifies which system sent the data. The destination identifies the intended receiving system.
*/
@interface GCHeaderEntity : GCEntity

// Methods:
/// @name Initializing

/** Initializes and returns a header.

 @param context The context in which to create the entity.
 @return A new header.
*/
+(instancetype)headerInContext:(GCContext *)context;

// Properties:
/// .  NB: required property.
@property (nonatomic) GCHeaderSourceAttribute *headerSource;

/// . GCDestinationAttribute
@property (nonatomic) NSArray *destinations;
/// . Contains instances of destinations
@property (nonatomic) NSMutableArray *mutableDestinations;

/// . 
@property (nonatomic) GCHeaderDateAttribute *headerDate;

/// .  NB: required property.
@property (nonatomic) GCSubmitterReferenceRelationship *submitterReference;

/// . GCSubmissionReferenceRelationship
@property (nonatomic) NSArray *submissionReferences;
/// . Contains instances of submissionReferences
@property (nonatomic) NSMutableArray *mutableSubmissionReferences;

/// . 
@property (nonatomic) GCFileAttribute *file;

/// . 
@property (nonatomic) GCCopyrightAttribute *copyright;

/// .  NB: required property.
@property (nonatomic) GCGedcomAttribute *gedcom;

/// .  NB: required property.
@property (nonatomic) GCCharacterSetAttribute *characterSet;

/// . 
@property (nonatomic) GCLanguageAttribute *language;

/// . 
@property (nonatomic) GCPlaceFormatSpecifierAttribute *placeFormatSpecifier;

/// . 
@property (nonatomic) GCNoteEmbeddedAttribute *noteEmbedded;


@end

