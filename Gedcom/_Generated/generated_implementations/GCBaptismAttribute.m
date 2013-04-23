/*
 This file was autogenerated by tags.py 
 */

#import "GCBaptismAttribute.h"

#import "GCObject_internal.h"

#import "GCAddressAttribute.h"
#import "GCAgeAttribute.h"
#import "GCCauseAttribute.h"
#import "GCDateAttribute.h"
#import "GCMultimediaEmbeddedAttribute.h"
#import "GCMultimediaReferenceRelationship.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPhoneNumberAttribute.h"
#import "GCPlaceAttribute.h"
#import "GCResponsibleAgencyAttribute.h"
#import "GCSourceCitationRelationship.h"
#import "GCSourceEmbeddedAttribute.h"
#import "GCTypeDescriptionAttribute.h"

@implementation GCBaptismAttribute {
	GCTypeDescriptionAttribute *_typeDescription;
	GCDateAttribute *_date;
	GCPlaceAttribute *_place;
	GCAddressAttribute *_address;
	GCPhoneNumberAttribute *_phoneNumber;
	GCAgeAttribute *_age;
	GCResponsibleAgencyAttribute *_responsibleAgency;
	GCCauseAttribute *_cause;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_multimediaReferences;
	NSMutableArray *_multimediaEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a baptism.

 
 @return A new baptism.
*/
+(instancetype)baptism
{
	return [[self alloc] init];
}
/** Initializes and returns a baptism.

 @param value The value as a GCValue object.
 @return A new baptism.
*/
+(instancetype)baptismWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a baptism.

 @param value The value as an NSString.
 @return A new baptism.
*/
+(instancetype)baptismWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		// initialize ivars, if any:
		_sourceCitations = [NSMutableArray array];
		_sourceEmbeddeds = [NSMutableArray array];
		_multimediaReferences = [NSMutableArray array];
		_multimediaEmbeddeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic eventDetails;
@dynamic typeDescription;
@dynamic date;
@dynamic place;
@dynamic address;
@dynamic phoneNumber;
@dynamic age;
@dynamic responsibleAgency;
@dynamic cause;
@dynamic sources;
@synthesize sourceCitations = _sourceCitations;

- (NSMutableArray *)mutableSourceCitations
{
	return [self mutableArrayValueForKey:@"sourceCitations"];
}

@synthesize sourceEmbeddeds = _sourceEmbeddeds;

- (NSMutableArray *)mutableSourceEmbeddeds
{
	return [self mutableArrayValueForKey:@"sourceEmbeddeds"];
}

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


@end

