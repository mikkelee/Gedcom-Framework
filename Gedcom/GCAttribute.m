//
//  GCAttribute.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAttribute.h"

#import "GCNode.h"

#import "GCObject_internal.h"
#import "GCValue_internal.h"

@implementation GCAttribute

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    if (![key isEqualToString:@"value"]) {
        [keyPaths addObject:@"value"];
    }
    
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
    
    [super setSubNodes:gedcomNode.subNodes];
}

#pragma mark Comparison

- (NSComparisonResult)compare:(GCAttribute *)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if (self.value != other.value) {
        return [self.value compare:other.value];
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
    
    return [NSString stringWithFormat:@"%@<%@: %p> (describing: %p value: %@) {\n%@%@};\n", indent, [self className], self, self.describedObject, self.value, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark Objective-C properties

- (void)setValue:(GCValue *)value
{
    NSParameterAssert(!value || [value isKindOfClass:[GCValue class]]);
    _value = value;
}

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

- (id)initWithValue:(GCValue *)value
{
    self = [self init];
    
    if (self) {
        self.value = value;
    }
    
    return self;
}

- (id)initWithGedcomStringValue:(NSString *)value
{
    self = [self init];
    
    if (self) {
        [self setValueWithGedcomString:value];
    }
    
    return self;
}

- (void)setValueWithGedcomString:(NSString *)string
{
    NSParameterAssert(self.gedTag.valueType);
    
    self.value = [self.gedTag.valueType valueWithGedcomString:string];
}

@end
