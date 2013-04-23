/*
 This file was autogenerated by tags.py 
 */

#import "GCAttribute.h"

@class GCGivenNameAttribute;
@class GCNamePrefixAttribute;
@class GCNameSuffixAttribute;
@class GCNicknameAttribute;
@class GCNoteEmbeddedAttribute;
@class GCNoteReferenceRelationship;
@class GCSourceCitationRelationship;
@class GCSourceEmbeddedAttribute;
@class GCSurnameAttribute;
@class GCSurnamePrefixAttribute;

/**
 
*/
@interface GCPersonalNameAttribute : GCAttribute

// Methods:
/** Initializes and returns a personalName.

 
 @return A new personalName.
*/
+(instancetype)personalName;
/** Initializes and returns a personalName.

 @param value The value as a GCValue object.
 @return A new personalName.
*/
+(instancetype)personalNameWithValue:(GCValue *)value;
/** Initializes and returns a personalName.

 @param value The value as an NSString.
 @return A new personalName.
*/
+(instancetype)personalNameWithGedcomStringValue:(NSString *)value;

// Properties:
/// . 
@property (nonatomic) GCNamePrefixAttribute *namePrefix;

/// . 
@property (nonatomic) GCGivenNameAttribute *givenName;

/// . 
@property (nonatomic) GCNicknameAttribute *nickname;

/// . 
@property (nonatomic) GCSurnamePrefixAttribute *surnamePrefix;

/// . 
@property (nonatomic) GCSurnameAttribute *surname;

/// . 
@property (nonatomic) GCNameSuffixAttribute *nameSuffix;

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

