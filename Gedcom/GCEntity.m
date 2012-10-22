//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCString.h"

#import "GCChangeInfoAttribute.h"

#import "GCContext_internal.h"

#import "GCObject_internal.h"

@interface GCEntity ()

@property (nonatomic) NSDate *modificationDate;
@property GCChangeInfoAttribute *changeInfo;

@end

@implementation GCEntity {
    GCContext *_context;
}

#pragma mark Initialization

//COV_NF_START
- (id)init
{
    NSLog(@"You must use -initInContext: to initialize a GCEntity!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
//COV_NF_END

- (id)initInContext:(GCContext *)context
{
    NSLog(@"You must override -initInContext: in your subclass!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)_initWithType:(NSString *)type inContext:(GCContext *)context
{
    GCParameterAssert(type);
    GCParameterAssert(context);
    
    self = [self _initWithType:type];
    
    if (self) {
		_context = context;
        _isBuildingFromGedcom = NO;
        [_context.mutableEntities addObject:self];
    }
    
    return self;
}

#pragma mark Convenience constructors

- (id)initWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    if (tag.isCustom) {
        self = [self _initWithType:tag.name inContext:context];
    } else {
        self = [self initInContext:context];
    }
    
    if (self) {
        _isBuildingFromGedcom = YES;
        
        if (tag.hasXref)
            [self.context _setXref:node.xref forEntity:self];
        
        if (tag.hasValue)
            self.value = [GCString valueWithGedcomString:node.gedValue];
        
        
        [self addPropertiesWithGedcomNodes:node.subNodes];
        
        _isBuildingFromGedcom = NO;
    }
    
    return self;
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if (self.type != [(GCProperty *)other type]) {
        return [self.type compare:[(GCProperty *)other type]];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_context forKey:@"context"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSString *indent = @"";
    for (NSUInteger i = 0; i < level; i++) {
        indent = [NSString stringWithFormat:@"%@%@", indent, @"  "];
    }
    
    NSString *extraValues;
    if (self.gedTag.hasXref)
        extraValues = [NSString stringWithFormat:@"xref: %@", [_context _xrefForEntity:self]];
    else if (self.gedTag.hasValue)
        extraValues = [NSString stringWithFormat:@"value: %@", self.value];
    
    return [NSString stringWithFormat:@"%@<%@: %p> (%@) {\n%@%@};\n", indent, [self className], self, extraValues, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark Objective-C properties

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:self.gedTag.hasValue ? self.value.gedcomString : nil
								  xref:self.gedTag.hasXref ? [self.context _xrefForEntity:self] : nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    NSParameterAssert(!self.gedTag.hasXref || [gedcomNode.xref isEqualToString:[self.context _xrefForEntity:self]]);
    
    [super setSubNodes:gedcomNode.subNodes];
}

- (NSString *)displayValue
{
    if (self.gedTag.hasXref)
        return [self.context _xrefForEntity:self];
    else
        return self.value.displayString;
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue 
                                           attributes:self.gedTag.hasXref ? @{NSLinkAttributeName: [self.context _xrefForEntity:self]} : nil];
}

- (GCObject *)rootObject
{
    return self;
}

@synthesize value = _value;

- (void)setValue:(GCString *)value
{
    NSParameterAssert(self.gedTag.hasValue);
    
    _value = value;
}

@synthesize context = _context;

- (NSDate *)modificationDate
{
    return self.changeInfo.modificationDate;
}

- (void)setModificationDate:(NSDate *)modificationDate
{
    if (!modificationDate) {
        if (!self.changeInfo.notes) {
            self.changeInfo = nil;
        }
    } else {
        if (!self.changeInfo) {
            self.changeInfo = [[GCChangeInfoAttribute alloc] init];
        }
    }
    
    [self.changeInfo setValue:modificationDate forKey:@"modificationDate"];
}

- (void)didChangeValueForKey:(NSString *)key
{
    if (!_isBuildingFromGedcom && [self.validPropertyTypes containsObject:@"changeInfo"]) {
        self.modificationDate = [NSDate date];
    }
    
    [super didChangeValueForKey:key];
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
    if (!_isBuildingFromGedcom && [self.validPropertyTypes containsObject:@"changeInfo"]) {
        self.modificationDate = [NSDate date];
    }
    
    [super didChange:changeKind valuesAtIndexes:indexes forKey:key];
}

@dynamic changeInfo;

@end
