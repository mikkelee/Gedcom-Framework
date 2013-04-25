/*
 This file was autogenerated by tags.py 
 */

#import "GCSourceCitationRelationship.h"

#import "GCObject_internal.h"

#import "GCDataAttribute.h"
#import "GCEventCitedAttribute.h"
#import "GCMultimediaEmbeddedAttribute.h"
#import "GCMultimediaReferenceRelationship.h"
#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPageAttribute.h"
#import "GCQualityOfDataAttribute.h"

@implementation GCSourceCitationRelationship {
	GCPageAttribute *_page;
	GCDataAttribute *_data;
	GCEventCitedAttribute *_eventCited;
	GCQualityOfDataAttribute *_qualityOfData;
	NSMutableArray *_multimediaReferences;
	NSMutableArray *_multimediaEmbeddeds;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/// @name Initializing

/** Initializes and returns a sourceCitation.

 
 @return A new sourceCitation.
*/
+(instancetype)sourceCitation
{
	return [[self alloc] init];
}
- (instancetype)init
{
	self = [super init];
	
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
@dynamic page;
@dynamic data;
@dynamic eventCited;
@dynamic qualityOfData;
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

