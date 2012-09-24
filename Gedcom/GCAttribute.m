//
//  GCAttribute.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAttribute.h"

#import "GCNode.h"

#import "GCEntity.h"

#import "GCValue.h"
#import "GCAge.h"
#import "GCDate.h"

#import "GCObject_internal.h"
#import "GCValue_internal.h"

@implementation GCAttribute

#pragma mark Initialization

- (id)initForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    self = [super initForObject:object withGedcomNode:node];
    
    if (self) {
        [self setValueWithGedcomString:node.gedValue];
    }
    
    return self;
}

#pragma mark Convenience constructors

+ (id)attributeForObject:(GCObject *)object withGedcomNode:(GCNode *)node
{
    return [[self alloc] initForObject:object withGedcomNode:node];
}

+ (id)attributeWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    [keyPaths addObject:@"value"];
    [keyPaths removeObject:key];
    
    return keyPaths;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:self.value.gedcomString
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    [self setValueWithGedcomString:gedcomNode.gedValue];
    
    [super setGedcomNode:gedcomNode];       
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if (self.value != [(GCAttribute *)other value]) {
        return [self.value compare:[(GCAttribute *)other value]];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _value = [aDecoder decodeObjectForKey:@"value"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_value forKey:@"value"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSString *indent = @"";
    for (NSUInteger i = 0; i < level; i++) {
        indent = [NSString stringWithFormat:@"%@%@", indent, @"  "];
    }
    
    return [NSString stringWithFormat:@"%@<%@: %p> (value: %@) {\n%@%@};\n", indent, [self className], self, self.value, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark Objective-C properties

- (NSString *)displayValue
{
    return self.value.displayString;
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue];
}

@end

@implementation GCAttribute (GCConvenienceMethods)

+ (id)attributeWithType:(NSString *)type value:(GCValue *)value
{
    GCAttribute *attribute = [self attributeWithType:type];
    
    attribute.value = value;
    
    return attribute;
}

+ (id)attributeWithType:(NSString *)type gedcomStringValue:(NSString *)value
{
    GCAttribute *attribute = [self attributeWithType:type];
    
    [attribute setValueWithGedcomString:value];
    
    return attribute;
}

- (void)setValueWithGedcomString:(NSString *)string
{
    NSParameterAssert(self.gedTag.valueType);
    
    self.value = [self.gedTag.valueType valueWithGedcomString:string];
}

@end

@implementation GCAttribute (GCValidationMethods)

- (BOOL)validateObject:(NSError **)outError
{
    BOOL isValid = YES;
    
    NSError *returnError = nil;
    
    NSError *err = nil;
    
    BOOL superValid = [super validateObject:&err];
    
    if (!superValid) {
        isValid &= NO;
        returnError = combineErrors(returnError, err);
    }
    
    returnError = combineErrors(returnError, err);
    
    if (self.gedTag.valueType) {
        if (_value == nil) {
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDoman
                                                                         code:GCValueMissingError
                                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Value is missing for %@ (should be a %@)",  self.type, self.gedTag.valueType], NSAffectedObjectsErrorKey: self}]);
            isValid &= NO;
        } else if (![_value isKindOfClass:self.gedTag.valueType]) {
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDoman
                                                                         code:GCIncorrectValueTypeError
                                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Value %@ is incorrect type for %@ (should be %@)", _value, self.type, self.gedTag.valueType], NSAffectedObjectsErrorKey: self}]);
            isValid &= NO;
        } else if ([self.gedTag.allowedValues count] > 0 && ![_value _isContainedInArray:self.gedTag.allowedValues]) {
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDoman
                                                                         code:GCIncorrectValueTypeError
                                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Value %@ is not allowed for %@ (should be one of %@)", _value, self.type, self.gedTag.allowedValues], NSAffectedObjectsErrorKey: self}]);
            isValid &= NO;
        }
    }
    
    if (!isValid) {
        *outError = returnError;
    }
    
    return isValid;
}

@end
