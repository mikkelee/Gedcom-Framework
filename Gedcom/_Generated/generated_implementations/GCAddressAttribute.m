/*
 This file was autogenerated by tags.py 
 */

#import "GCAddressAttribute.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"
#import "GCProperty_internal.h"

#import "GCAddressLine1Attribute.h"
#import "GCAddressLine2Attribute.h"
#import "GCCityAttribute.h"
#import "GCCountryAttribute.h"
#import "GCPostalCodeAttribute.h"
#import "GCStateAttribute.h"

@implementation GCAddressAttribute {
	GCAddressLine1Attribute *_addressLine1;
	GCAddressLine2Attribute *_addressLine2;
	GCCityAttribute *_city;
	GCStateAttribute *_state;
	GCPostalCodeAttribute *_postalCode;
	GCCountryAttribute *_country;
}

// Methods:
/** Initializes and returns a address.

 
 @return A new address.
*/
+(GCAddressAttribute *)address
{
	return [[self alloc] init];
}
/** Initializes and returns a address.

 @param value The value as a GCValue object.
 @return A new address.
*/
+(GCAddressAttribute *)addressWithValue:(GCValue *)value
{
	return [[self alloc] initWithValue:value];
}
/** Initializes and returns a address.

 @param value The value as an NSString.
 @return A new address.
*/
+(GCAddressAttribute *)addressWithGedcomStringValue:(NSString *)value
{
	return [[self alloc] initWithGedcomStringValue:value];
}
- (id)init
{
	self = [super _initWithType:@"address"];
	
	if (self) {
		// initialize ivars, if any:

	}
	
	return self;
}


// Properties:

- (void)setAddressLine1:(GCProperty *)obj
{
	[(GCAddressAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setAddressLine1:_addressLine1];
	[self.context.undoManager setActionName:@"Undo addressLine1"]; //TODO
	
	if (_addressLine1) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_addressLine1 = (id)obj;
}

- (GCAddressLine1Attribute *)addressLine1
{
	return _addressLine1;
}


- (void)setAddressLine2:(GCProperty *)obj
{
	[(GCAddressAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setAddressLine2:_addressLine2];
	[self.context.undoManager setActionName:@"Undo addressLine2"]; //TODO
	
	if (_addressLine2) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_addressLine2 = (id)obj;
}

- (GCAddressLine2Attribute *)addressLine2
{
	return _addressLine2;
}


- (void)setCity:(GCProperty *)obj
{
	[(GCAddressAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setCity:_city];
	[self.context.undoManager setActionName:@"Undo city"]; //TODO
	
	if (_city) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_city = (id)obj;
}

- (GCCityAttribute *)city
{
	return _city;
}


- (void)setState:(GCProperty *)obj
{
	[(GCAddressAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setState:_state];
	[self.context.undoManager setActionName:@"Undo state"]; //TODO
	
	if (_state) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_state = (id)obj;
}

- (GCStateAttribute *)state
{
	return _state;
}


- (void)setPostalCode:(GCProperty *)obj
{
	[(GCAddressAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setPostalCode:_postalCode];
	[self.context.undoManager setActionName:@"Undo postalCode"]; //TODO
	
	if (_postalCode) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_postalCode = (id)obj;
}

- (GCPostalCodeAttribute *)postalCode
{
	return _postalCode;
}


- (void)setCountry:(GCProperty *)obj
{
	[(GCAddressAttribute *)[self.context.undoManager prepareWithInvocationTarget:self] setCountry:_country];
	[self.context.undoManager setActionName:@"Undo country"]; //TODO
	
	if (_country) {
		obj.describedObject = nil;
	}
	
	if (obj.describedObject) {
		[obj.describedObject.mutableProperties removeObject:obj];
	}
	
	obj.describedObject = self;
	
	_country = (id)obj;
}

- (GCCountryAttribute *)country
{
	return _country;
}


@end

