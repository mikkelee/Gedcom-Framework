/*
 This file was autogenerated by tags.py 
 */

#import "GCChildInFamilyRelationship.h"

#import "GCObject_internal.h"

#import "GCNoteEmbeddedAttribute.h"
#import "GCNoteReferenceRelationship.h"
#import "GCPedigreeAttribute.h"

@implementation GCChildInFamilyRelationship {
	GCPedigreeAttribute *_pedigree;
	NSMutableArray *_noteReferences;
	NSMutableArray *_noteEmbeddeds;
}

// Methods:
/** Initializes and returns a childInFamily.

 
 @return A new childInFamily.
*/
+(instancetype)childInFamily
{
	return [[self alloc] init];
}
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		// initialize ivars, if any:
		_noteReferences = [NSMutableArray array];
		_noteEmbeddeds = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic pedigree;
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

