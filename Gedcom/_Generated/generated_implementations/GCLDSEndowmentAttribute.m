/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSEndowmentAttribute.h"

#import "GCObject_internal.h"

#import "GCDateAttribute.h"
#import "GCLDSEndowmentStatusAttribute.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPlaceAttribute.h"
#import "GCSourceCitationRelationship.h"
#import "GCSourceEmbeddedAttribute.h"
#import "GCTempleAttribute.h"

@implementation GCLDSEndowmentAttribute {
	GCLDSEndowmentStatusAttribute *_lDSEndowmentStatus;
	GCDateAttribute *_date;
	GCTempleAttribute *_temple;
	GCPlaceAttribute *_place;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

+ (GCTag *)gedTag
{
	return [GCTag tagWithClassName:@"GCLDSEndowmentAttribute"];
}

// Methods:
/** Initializes and returns a lDSEndowment.

 
 @return A new lDSEndowment.
*/
+(GCLDSEndowmentAttribute *)lDSEndowment
{
	return [[self alloc] init];
}
/** Initializes and returns a lDSEndowment.

 @param value The value as a GCValue object.
 @return A new lDSEndowment.
*/
+(GCLDSEndowmentAttribute *)lDSEndowmentWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a lDSEndowment.

 @param value The value as an NSString.
 @return A new lDSEndowment.
*/
+(GCLDSEndowmentAttribute *)lDSEndowmentWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"lDSEndowment"];
	
	if (self) {
		// initialize ivars, if any:
		_sourceCitations = [NSMutableArray array];
		_sourceEmbeddeds = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic lDSEndowmentStatus;
@dynamic date;
@dynamic temple;
@dynamic place;
@dynamic sources;
@dynamic sourceCitations;
@dynamic mutableSourceCitations;
@dynamic sourceEmbeddeds;
@dynamic mutableSourceEmbeddeds;
@dynamic notes;
@dynamic noteReferences;
@dynamic mutableNoteReferences;
@dynamic noteEmbeddeds;
@dynamic mutableNoteEmbeddeds;

@end

