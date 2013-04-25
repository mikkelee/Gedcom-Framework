/*
 This file was autogenerated by tags.py 
 */

#import "GCRecord.h"

@class GCAnnulmentAttribute;
@class GCCensusAttribute;
@class GCChangeInfoAttribute;
@class GCChildRelationship;
@class GCDivorceAttribute;
@class GCDivorceFiledAttribute;
@class GCEngagementAttribute;
@class GCGenericEventAttribute;
@class GCHusbandRelationship;
@class GCLDSSealingSpouseAttribute;
@class GCMarriageAttribute;
@class GCMarriageBannAttribute;
@class GCMarriageContractAttribute;
@class GCMarriageLicenseAttribute;
@class GCMarriageSettlementAttribute;
@class GCMultimediaEmbeddedAttribute;
@class GCMultimediaReferenceRelationship;
@class GCNoteEmbeddedAttribute;
@class GCNoteReferenceRelationship;
@class GCNumberOfChildrenAttribute;
@class GCRecordIdNumberAttribute;
@class GCSourceCitationRelationship;
@class GCSourceEmbeddedAttribute;
@class GCSubmitterReferenceRelationship;
@class GCUserReferenceNumberAttribute;
@class GCWifeRelationship;

/**
 The family record is used to record marriages, common law marriages, and family unions caused by two people becoming the parents of a child.
*/
@interface GCFamilyRecord : GCRecord

// Methods:
/// @name Initializing

/** Initializes and returns a family.

 @param context The context in which to create the entity.
 @return A new family.
*/
+(instancetype)familyInContext:(GCContext *)context;

// Properties:
/// @name Accessing family events

/// Property for accessing the following properties
@property (nonatomic) NSArray *familyEvents;

/// @name Accessing family events 

///Also contained in familyEvents. . GCAnnulmentAttribute
@property (nonatomic) NSArray *annulments;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of annulments
@property (nonatomic) NSMutableArray *mutableAnnulments;

/// @name Accessing family events 

///Also contained in familyEvents. . GCCensusAttribute
@property (nonatomic) NSArray *censuses;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of censuses
@property (nonatomic) NSMutableArray *mutableCensuses;

/// @name Accessing family events 

///Also contained in familyEvents. . GCDivorceAttribute
@property (nonatomic) NSArray *divorces;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of divorces
@property (nonatomic) NSMutableArray *mutableDivorces;

/// @name Accessing family events 

///Also contained in familyEvents. . GCDivorceFiledAttribute
@property (nonatomic) NSArray *divorceFileds;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of divorceFileds
@property (nonatomic) NSMutableArray *mutableDivorceFileds;

/// @name Accessing family events 

///Also contained in familyEvents. . GCEngagementAttribute
@property (nonatomic) NSArray *engagements;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of engagements
@property (nonatomic) NSMutableArray *mutableEngagements;

/// @name Accessing family events 

///Also contained in familyEvents. . GCMarriageAttribute
@property (nonatomic) NSArray *marriages;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of marriages
@property (nonatomic) NSMutableArray *mutableMarriages;

/// @name Accessing family events 

///Also contained in familyEvents. . GCMarriageBannAttribute
@property (nonatomic) NSArray *marriageBanns;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of marriageBanns
@property (nonatomic) NSMutableArray *mutableMarriageBanns;

/// @name Accessing family events 

///Also contained in familyEvents. . GCMarriageContractAttribute
@property (nonatomic) NSArray *marriageContracts;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of marriageContracts
@property (nonatomic) NSMutableArray *mutableMarriageContracts;

/// @name Accessing family events 

///Also contained in familyEvents. . GCMarriageLicenseAttribute
@property (nonatomic) NSArray *marriageLicenses;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of marriageLicenses
@property (nonatomic) NSMutableArray *mutableMarriageLicenses;

/// @name Accessing family events 

///Also contained in familyEvents. . GCMarriageSettlementAttribute
@property (nonatomic) NSArray *marriageSettlements;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of marriageSettlements
@property (nonatomic) NSMutableArray *mutableMarriageSettlements;

/// @name Accessing family events 

///Also contained in familyEvents. . GCGenericEventAttribute
@property (nonatomic) NSArray *genericEvents;
/// @name Accessing family events 

///Also contained in familyEvents. . Contains instances of genericEvents
@property (nonatomic) NSMutableArray *mutableGenericEvents;

/// . 
@property (nonatomic) GCHusbandRelationship *husband;

/// . 
@property (nonatomic) GCWifeRelationship *wife;

/// . GCChildRelationship
@property (nonatomic) NSArray *children;
/// . Contains instances of children
@property (nonatomic) NSMutableArray *mutableChildren;

/// . 
@property (nonatomic) GCNumberOfChildrenAttribute *numberOfChildren;

/// . GCSubmitterReferenceRelationship
@property (nonatomic) NSArray *submitterReferences;
/// . Contains instances of submitterReferences
@property (nonatomic) NSMutableArray *mutableSubmitterReferences;

/// . GCLDSSealingSpouseAttribute
@property (nonatomic) NSArray *lDSSealingSpouses;
/// . Contains instances of lDSSealingSpouses
@property (nonatomic) NSMutableArray *mutableLDSSealingSpouses;

/// @name Accessing sources

/// Property for accessing the following properties
@property (nonatomic) NSArray *sources;

/// @name Accessing sources 

///Also contained in sources. . GCSourceCitationRelationship
@property (nonatomic) NSArray *sourceCitations;
/// @name Accessing sources 

///Also contained in sources. . Contains instances of sourceCitations
@property (nonatomic) NSMutableArray *mutableSourceCitations;

/// @name Accessing sources 

///Also contained in sources. . GCSourceEmbeddedAttribute
@property (nonatomic) NSArray *sourceEmbeddeds;
/// @name Accessing sources 

///Also contained in sources. . Contains instances of sourceEmbeddeds
@property (nonatomic) NSMutableArray *mutableSourceEmbeddeds;

/// @name Accessing multimedias

/// Property for accessing the following properties
@property (nonatomic) NSArray *multimedias;

/// @name Accessing multimedias 

///Also contained in multimedias. . GCMultimediaReferenceRelationship
@property (nonatomic) NSArray *multimediaReferences;
/// @name Accessing multimedias 

///Also contained in multimedias. . Contains instances of multimediaReferences
@property (nonatomic) NSMutableArray *mutableMultimediaReferences;

/// @name Accessing multimedias 

///Also contained in multimedias. . GCMultimediaEmbeddedAttribute
@property (nonatomic) NSArray *multimediaEmbeddeds;
/// @name Accessing multimedias 

///Also contained in multimedias. . Contains instances of multimediaEmbeddeds
@property (nonatomic) NSMutableArray *mutableMultimediaEmbeddeds;

/// @name Accessing notes

/// Property for accessing the following properties
@property (nonatomic) NSArray *notes;

/// @name Accessing notes 

///Also contained in notes. . GCNoteReferenceRelationship
@property (nonatomic) NSArray *noteReferences;
/// @name Accessing notes 

///Also contained in notes. . Contains instances of noteReferences
@property (nonatomic) NSMutableArray *mutableNoteReferences;

/// @name Accessing notes 

///Also contained in notes. . GCNoteEmbeddedAttribute
@property (nonatomic) NSArray *noteEmbeddeds;
/// @name Accessing notes 

///Also contained in notes. . Contains instances of noteEmbeddeds
@property (nonatomic) NSMutableArray *mutableNoteEmbeddeds;

/// . GCUserReferenceNumberAttribute
@property (nonatomic) NSArray *userReferenceNumbers;
/// . Contains instances of userReferenceNumbers
@property (nonatomic) NSMutableArray *mutableUserReferenceNumbers;

/// . 
@property (nonatomic) GCRecordIdNumberAttribute *recordIdNumber;

/// . 
@property (nonatomic) GCChangeInfoAttribute *changeInfo;


@end

