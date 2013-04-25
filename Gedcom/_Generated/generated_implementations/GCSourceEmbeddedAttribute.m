/*
 This file was autogenerated by tags.py 
 */

#import "GCSourceEmbeddedAttribute.h"

#import "GCObject_internal.h"

#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCTextAttribute.h"

@implementation GCSourceEmbeddedAttribute {
	NSMutableArray *_texts;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/// @name Initializing

/** Initializes and returns a sourceEmbedded.

 
 @return A new sourceEmbedded.
*/
+(instancetype)sourceEmbedded
{
	return [[self alloc] init];
}
/// @name Initializing

/** Initializes and returns a sourceEmbedded.

 @param value The value as a GCValue object.
 @return A new sourceEmbedded.
*/
+(instancetype)sourceEmbeddedWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/// @name Initializing

/** Initializes and returns a sourceEmbedded.

 @param value The value as an NSString.
 @return A new sourceEmbedded.
*/
+(instancetype)sourceEmbeddedWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		// initialize ivars, if any:
		_texts = [NSMutableArray array];
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@synthesize texts = _texts;

- (NSMutableArray *)mutableTexts
{
	return [self mutableArrayValueForKey:@"texts"];
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

