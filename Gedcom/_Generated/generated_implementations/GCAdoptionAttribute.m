/*
 This file was autogenerated by tags.py 
 */

#import "GCAdoptionAttribute.h"

#import "GCObject_internal.h"

#import "GCAddressAttribute.h"
#import "GCAdoptedIntoFamilyRelationship.h"
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

@implementation GCAdoptionAttribute {
	GCAdoptedIntoFamilyRelationship *_adoptedIntoFamily;
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

+ (GCTag *)gedTag
{
	return [GCTag tagWithClassName:@"GCAdoptionAttribute"];
}

// Methods:
/** Initializes and returns a adoption.

 
 @return A new adoption.
*/
+(GCAdoptionAttribute *)adoption
{
	return [[self alloc] init];
}
/** Initializes and returns a adoption.

 @param value The value as a GCValue object.
 @return A new adoption.
*/
+(GCAdoptionAttribute *)adoptionWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a adoption.

 @param value The value as an NSString.
 @return A new adoption.
*/
+(GCAdoptionAttribute *)adoptionWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"adoption"];
	
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
@dynamic adoptedIntoFamily;
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
@dynamic sourceCitations;
@dynamic mutableSourceCitations;
@dynamic sourceEmbeddeds;
@dynamic mutableSourceEmbeddeds;
@dynamic multimedias;
@dynamic multimediaReferences;
@dynamic mutableMultimediaReferences;
@dynamic multimediaEmbeddeds;
@dynamic mutableMultimediaEmbeddeds;
@dynamic notes;
@dynamic noteReferences;
@dynamic mutableNoteReferences;
@dynamic noteEmbeddeds;
@dynamic mutableNoteEmbeddeds;

@end

