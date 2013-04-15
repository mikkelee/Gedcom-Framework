/*
 This file was autogenerated by tags.py 
 */

#import "GCAdoptedIntoFamilyRelationship.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

#import "GCAdoptedByWhichParentAttribute.h"

@implementation GCAdoptedIntoFamilyRelationship {
	GCAdoptedByWhichParentAttribute *_adoptedByWhichParent;
}

// Methods:
/** Initializes and returns a adoptedIntoFamily.

 
 @return A new adoptedIntoFamily.
*/
+(GCAdoptedIntoFamilyRelationship *)adoptedIntoFamily
{
	return [[self alloc] init];
}
- (id)init
{
	self = [super _initWithType:@"adoptedIntoFamily"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:

- (void)setAdoptedByWhichParent:(id)obj
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *formatString = [frameworkBundle localizedStringForKey:@"Undo %@"
															  value:@"Undo %@"
															  table:@"Misc"];
    
    NSString *typeName = [frameworkBundle localizedStringForKey:self.type
															  value:self.type
															  table:@"Misc"];
    
	[(GCAdoptedIntoFamilyRelationship *)[self.context.undoManager prepareWithInvocationTarget:self] setAdoptedByWhichParent:_adoptedByWhichParent];
	[self.context.undoManager setActionName:[NSString stringWithFormat:formatString, typeName]];
	
	if (_adoptedByWhichParent) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_adoptedByWhichParent = (id)obj;
}

- (GCAdoptedByWhichParentAttribute *)adoptedByWhichParent
{
	return _adoptedByWhichParent;
}


@end
