/*
 This file was autogenerated by tags.py 
 */

#import "GCLDSConfirmationAttribute.h"

#import "GCDateAttribute.h"
#import "GCLDSBaptismStatusAttribute.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPlaceAttribute.h"
#import "GCSourceCitationRelationship.h"
#import "GCSourceEmbeddedAttribute.h"
#import "GCTempleAttribute.h"

@implementation GCLDSConfirmationAttribute {
	GCLDSBaptismStatusAttribute *_lDSBaptismStatus;
	GCDateAttribute *_date;
	GCTempleAttribute *_temple;
	GCPlaceAttribute *_place;
	NSMutableArray *_sourceCitations;
	NSMutableArray *_sourceEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/// @name Initializing

/** Initializes and returns a lDSConfirmation.

 
 @return A new lDSConfirmation.
*/
+(instancetype)lDSConfirmation
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a lDSConfirmation.

 @param value The value as a GCValue object.
 @return A new lDSConfirmation.
*/
+(instancetype)lDSConfirmationWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a lDSConfirmation.

 @param value The value as an NSString.
 @return A new lDSConfirmation.
*/
+(instancetype)lDSConfirmationWithGedcomStringValue:(NSString *)value
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
@dynamic lDSBaptismStatus;
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

