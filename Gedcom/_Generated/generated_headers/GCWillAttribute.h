/*
 This file was autogenerated by tags.py 
 */

#import "GCIndividualEventAttribute.h"

@class GCAddressAttribute;
@class GCAgeAttribute;
@class GCCauseAttribute;
@class GCDateAttribute;
@class GCMultimediaEmbeddedAttribute;
@class GCMultimediaReferenceRelationship;
@class GCNoteEmbeddedAttribute;
@class GCNoteReferenceRelationship;
@class GCPhoneNumberAttribute;
@class GCPlaceAttribute;
@class GCResponsibleAgencyAttribute;
@class GCSourceCitationRelationship;
@class GCSourceEmbeddedAttribute;
@class GCTypeDescriptionAttribute;

/**
 
*/
@interface GCWillAttribute : GCIndividualEventAttribute

// Methods:
/** Initializes and returns a will.

 
 @return A new will.
*/
+(instancetype)will;
/** Initializes and returns a will.

 @param value The value as a GCValue object.
 @return A new will.
*/
+(instancetype)willWithValue:(GCValue *)value;
/** Initializes and returns a will.

 @param value The value as an NSString.
 @return A new will.
*/
+(instancetype)willWithGedcomStringValue:(NSString *)value;

// Properties:
/// Property for accessing the following properties
@property (nonatomic) NSArray *eventDetails;

/// Also contained in eventDetails. . 
@property (nonatomic) GCTypeDescriptionAttribute *typeDescription;

/// Also contained in eventDetails. . 
@property (nonatomic) GCDateAttribute *date;

/// Also contained in eventDetails. . 
@property (nonatomic) GCPlaceAttribute *place;

/// Also contained in eventDetails. . 
@property (nonatomic) GCAddressAttribute *address;

/// Also contained in eventDetails. . 
@property (nonatomic) GCPhoneNumberAttribute *phoneNumber;

/// Also contained in eventDetails. . 
@property (nonatomic) GCAgeAttribute *age;

/// Also contained in eventDetails. . 
@property (nonatomic) GCResponsibleAgencyAttribute *responsibleAgency;

/// Also contained in eventDetails. . 
@property (nonatomic) GCCauseAttribute *cause;

/// Property for accessing the following properties
@property (nonatomic) NSArray *sources;

/// Also contained in sources. . GCSourceCitationRelationship
@property (nonatomic) NSArray *sourceCitations;
/// Also contained in sources. . sourceCitations
@property (nonatomic) NSMutableArray *mutableSourceCitations;

/// Also contained in sources. . GCSourceEmbeddedAttribute
@property (nonatomic) NSArray *sourceEmbeddeds;
/// Also contained in sources. . sourceEmbeddeds
@property (nonatomic) NSMutableArray *mutableSourceEmbeddeds;

/// Property for accessing the following properties
@property (nonatomic) NSArray *multimedias;

/// Also contained in multimedias. . GCMultimediaReferenceRelationship
@property (nonatomic) NSArray *multimediaReferences;
/// Also contained in multimedias. . multimediaReferences
@property (nonatomic) NSMutableArray *mutableMultimediaReferences;

/// Also contained in multimedias. . GCMultimediaEmbeddedAttribute
@property (nonatomic) NSArray *multimediaEmbeddeds;
/// Also contained in multimedias. . multimediaEmbeddeds
@property (nonatomic) NSMutableArray *mutableMultimediaEmbeddeds;

/// Property for accessing the following properties
@property (nonatomic) NSArray *notes;

/// Also contained in notes. . GCNoteReferenceRelationship
@property (nonatomic) NSArray *noteReferences;
/// Also contained in notes. . noteReferences
@property (nonatomic) NSMutableArray *mutableNoteReferences;

/// Also contained in notes. . GCNoteEmbeddedAttribute
@property (nonatomic) NSArray *noteEmbeddeds;
/// Also contained in notes. . noteEmbeddeds
@property (nonatomic) NSMutableArray *mutableNoteEmbeddeds;


@end

