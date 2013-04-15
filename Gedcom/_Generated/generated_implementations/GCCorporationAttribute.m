/*
 This file was autogenerated by tags.py 
 */

#import "GCCorporationAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

#import "GCAddressAttribute.h"
#import "GCPhoneNumberAttribute.h"

@implementation GCCorporationAttribute {
	GCAddressAttribute *_address;
	NSMutableArray *_phoneNumbers;
}

// Methods:
/** Initializes and returns a corporation.

 
 @return A new corporation.
*/
+(GCCorporationAttribute *)corporation
{
	return [[self alloc] init];
}
/** Initializes and returns a corporation.

 @param value The value as a GCValue object.
 @return A new corporation.
*/
+(GCCorporationAttribute *)corporationWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a corporation.

 @param value The value as an NSString.
 @return A new corporation.
*/
+(GCCorporationAttribute *)corporationWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"corporation"];
	
	if (self) {
		// initialize ivars, if any:
		_phoneNumbers = [NSMutableArray array];
	}
	
	return self;
}


// Properties:

- (void)setAddress:(id)obj
{
	[(GCCorporationAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setAddress:_address];
	[self.context.undoManager setActionName:@"Undo address"]; //TODO
	
	if (_address) {
		[obj setValue:nil forKey:@"describedObject"];
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
	_address = (id)obj;
}

- (GCAddressAttribute *)address
{
	return _address;
}


- (NSMutableArray *)mutablePhoneNumbers {
    return [self mutableArrayValueForKey:@"phoneNumbers"];
}

- (NSUInteger)countOfPhoneNumbers {
	return [_phoneNumbers count];
}

- (id)objectInPhoneNumbersAtIndex:(NSUInteger)index {
    return [_phoneNumbers objectAtIndex:index];
}
 
- (void)insertObject:(id)obj inPhoneNumbersAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCPhoneNumberAttribute class]]);
	
	[(GCCorporationAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] removeObjectFromPhoneNumbersAtIndex:index];
	[self.context.undoManager setActionName:@"Undo phoneNumbers"]; //TODO
	
	if ([obj valueForKey:@"describedObject"] == self) {
		return;
	}
	
	if ([obj valueForKey:@"describedObject"]) {
		[((GCObject *)[obj valueForKey:@"describedObject"]).mutableProperties removeObject:obj];
	}
	
	[obj setValue:self forKey:@"describedObject"];
	
    [_phoneNumbers insertObject:obj atIndex:index];
}

- (void)removeObjectFromPhoneNumbersAtIndex:(NSUInteger)index {
	[(GCCorporationAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] insertObject:_phoneNumbers[index] inPhoneNumbersAtIndex:index];
	[self.context.undoManager setActionName:@"Undo phoneNumbers"]; //TODO
	
	[((GCObject *)_phoneNumbers[index]) setValue:nil forKey:@"describedObject"];
	
    [_phoneNumbers removeObjectAtIndex:index];
}
	

@end

