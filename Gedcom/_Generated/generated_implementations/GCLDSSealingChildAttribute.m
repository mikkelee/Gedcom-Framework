/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSSealingChildAttribute.h"

#import "GCObject_internal.h"

#import "GCDateAttribute.h"
#import "GCLDSSealingChildStatusAttribute.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPlaceAttribute.h"
#import "GCSealedToFamilyRelationship.h"
#import "GCSourceCitationRelationship.h"
#import "GCSourceEmbeddedAttribute.h"
#import "GCTempleAttribute.h"

@implementation GCLDSSealingChildAttribute {
	GCLDSSealingChildStatusAttribute *_lDSSealingChildStatus;
	GCSealedToFamilyRelationship *_sealedToFamily;
	GCDateAttribute *_date;
	GCTempleAttribute *_temple;
	GCPlaceAttribute *_place;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a lDSSealingChild.

 
 @return A new lDSSealingChild.
*/
+(instancetype)lDSSealingChild
{
	return [[self alloc] init];
}
/** Initializes and returns a lDSSealingChild.

 @param value The value as a GCValue object.
 @return A new lDSSealingChild.
*/
+(instancetype)lDSSealingChildWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a lDSSealingChild.

 @param value The value as an NSString.
 @return A new lDSSealingChild.
*/
+(instancetype)lDSSealingChildWithGedcomStringValue:(NSString *)value
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
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic lDSSealingChildStatus;
@dynamic sealedToFamily;
@dynamic date;
@dynamic temple;
@dynamic place;
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

