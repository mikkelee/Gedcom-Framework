/*
 This file was autogenerated by tags.py 
 */

#import "GCSubmissionRecord.h"

#import "GCObject_internal.h"

#import "GCChangeInfoAttribute.h"
#import "GCFamilyFileAttribute.h"
#import "GCGenerationsOfAncestorsAttribute.h"
#import "GCGenerationsOfDescendantsAttribute.h"
#import "GCOrdinanceFlagAttribute.h"
#import "GCRecordIdNumberAttribute.h"
#import "GCSubmitterReferenceRelationship.h"
#import "GCTempleAttribute.h"
#import "GCUserReferenceNumberAttribute.h"

@implementation GCSubmissionRecord {
	GCSubmitterReferenceRelationship *_submitterReference;
	GCFamilyFileAttribute *_familyFile;
	GCTempleAttribute *_temple;
	GCGenerationsOfAncestorsAttribute *_generationsOfAncestors;
	GCGenerationsOfDescendantsAttribute *_generationsOfDescendants;
	GCOrdinanceFlagAttribute *_ordinanceFlag;
	NSMutableArray *_userReferenceNumbers;
	GCRecordIdNumberAttribute *_recordIdNumber;
	GCChangeInfoAttribute *_changeInfo;
}

// Methods:
/// @name Initializing

/** Initializes and returns a submission.

 @param context The context in which to create the entity.
 @return A new submission.
*/
+(instancetype)submissionInContext:(GCContext *)context
{
	return [[self alloc] initInContext:context];
}
- (instancetype)initInContext:(GCContext *)context
{
	self = [super initInContext:context];
	
	if (self) {
		// initialize ivars, if any:
		_userReferenceNumbers = [NSMutableArray array];
	}
	
	return self;
}


// Properties:
@dynamic submitterReference;
@dynamic familyFile;
@dynamic temple;
@dynamic generationsOfAncestors;
@dynamic generationsOfDescendants;
@dynamic ordinanceFlag;
@synthesize userReferenceNumbers = _userReferenceNumbers;

- (NSMutableArray *)mutableUserReferenceNumbers
{
	return [self mutableArrayValueForKey:@"userReferenceNumbers"];
}

@dynamic recordIdNumber;
@dynamic changeInfo;

@end

