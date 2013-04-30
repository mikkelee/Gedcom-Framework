/*
 This file was autogenerated by tags.py 
 */

#import "GCSourceRecord.h"

#import "GCAbbreviationAttribute.h"
#import "GCAuthorAttribute.h"
#import "GCChangeInfoAttribute.h"
#import "GCMultimediaEmbeddedAttribute.h"
#import "GCMultimediaReferenceRelationship.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPublicationFactsAttribute.h"
#import "GCRecordIdNumberAttribute.h"
#import "GCRepositoryCitationRelationship.h"
#import "GCSourceDataAttribute.h"
#import "GCTextAttribute.h"
#import "GCTitleAttribute.h"
#import "GCUserReferenceNumberAttribute.h"

@implementation GCSourceRecord {
	GCSourceDataAttribute *_sourceData;
	GCAuthorAttribute *_author;
	GCTitleAttribute *_title;
	GCAbbreviationAttribute *_abbreviation;
	GCPublicationFactsAttribute *_publicationFacts;
	GCTextAttribute *_text;
	GCRepositoryCitationRelationship *_repositoryCitation;
	NSMutableArray *_multimediaReferences;
	NSMutableArray *_multimediaEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
	GCUserReferenceNumberAttribute *_userReferenceNumber;
	GCRecordIdNumberAttribute *_recordIdNumber;
	GCChangeInfoAttribute *_changeInfo;
}

// Methods:
/// @name Initializing

/** Initializes and returns a source.

 @param context The context in which to create the entity.
 @return A new source.
*/
+(instancetype)sourceInContext:(GCContext *)context
{
	return [[self alloc] initInContext:context];
}
- (instancetype)initInContext:(GCContext *)context
{
	self = [super initInContext:context];
	
	if (self) {
		// initialize ivars, if any:
		_multimediaReferences = [NSMutableArray array];
		_multimediaEmbeddeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic sourceData;
@dynamic author;
@dynamic title;
@dynamic abbreviation;
@dynamic publicationFacts;
@dynamic text;
@dynamic repositoryCitation;
@dynamic multimedias;
@synthesize multimediaReferences = _multimediaReferences;

- (NSMutableArray *)mutableMultimediaReferences
{
	return [self mutableArrayValueForKey:@"multimediaReferences"];
}

@synthesize multimediaEmbeddeds = _multimediaEmbeddeds;

- (NSMutableArray *)mutableMultimediaEmbeddeds
{
	return [self mutableArrayValueForKey:@"multimediaEmbeddeds"];
}

@dynamic notes;
@synthesize noteReferences = _noteReferences;

- (NSMutableArray *)mutableNoteReferences
{
	return [self mutableArrayValueForKey:@"noteReferences"];
}

@synthesize noteEmbeddeds = _noteEmbeddeds;

- (NSMutableArray *)mutableNoteEmbeddeds
{
	return [self mutableArrayValueForKey:@"noteEmbeddeds"];
}

@dynamic userReferenceNumber;
@dynamic recordIdNumber;
@dynamic changeInfo;

@end

