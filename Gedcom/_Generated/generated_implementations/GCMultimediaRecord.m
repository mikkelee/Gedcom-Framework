/*
 This file was autogenerated by tags.py 
 */

#import "GCMultimediaRecord.h"

#import "GCBinaryObjectAttribute.h"
#import "GCChangeInfoAttribute.h"
#import "GCMultimediaFormatAttribute.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCRecordIdNumberAttribute.h"
#import "GCTitleAttribute.h"
#import "GCUserReferenceNumberAttribute.h"

@implementation GCMultimediaRecord {
	GCMultimediaFormatAttribute *_multimediaFormat;
	GCTitleAttribute *_title;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
	GCBinaryObjectAttribute *_binaryObject;
	NSMutableArray *_userReferenceNumbers;
	GCRecordIdNumberAttribute *_recordIdNumber;
	GCChangeInfoAttribute *_changeInfo;
}

// Methods:
/// @name Initializing

/** Initializes and returns a multimedia.

 @param context The context in which to create the entity.
 @return A new multimedia.
*/
+(instancetype)multimediaInContext:(GCContext *)context
{
	return [[self alloc] initInContext:context];
}
- (instancetype)initInContext:(GCContext *)context
{
	self = [super initInContext:context];
	
	if (self) {
		// initialize ivars, if any:
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
		_userReferenceNumbers = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic multimediaFormat;
@dynamic title;
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

@dynamic binaryObject;
@synthesize userReferenceNumbers = _userReferenceNumbers;

- (NSMutableArray *)mutableUserReferenceNumbers
{
	return [self mutableArrayValueForKey:@"userReferenceNumbers"];
}

@dynamic recordIdNumber;
@dynamic changeInfo;

@end

