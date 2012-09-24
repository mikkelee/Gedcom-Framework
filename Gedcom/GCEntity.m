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

#import "GCChangeInfoAttribute.h"

#import "GCContext_internal.h"

#import "GCObject_internal.h"

@interface GCEntity ()

@property (nonatomic) NSDate *modificationDate;

@end

@implementation GCEntity {
    GCContext *_context;
    BOOL _isBuildingFromGedcom;
}

#pragma mark Initialization

- (id)initWithType:(NSString *)type inContext:(GCContext *)context
{
    NSParameterAssert(type);
    NSParameterAssert(context);
    
    self = [super initWithType:type];
    
    if (self) {
		_context = context;
        _isBuildingFromGedcom = NO;
        [_context.allEntities addObject:self];
    }
    
    return self;    
}

#pragma mark Convenience constructors

+ (id)entityWithType:(NSString *)type inContext:(GCContext *)context
{
    return [[self alloc] initWithType:type inContext:context];
}

+ (id)entityWithGedcomNode:(GCNode *)node inContext:(GCContext *)context
{
	GCEntity *entity = [self entityWithType:[[GCTag rootTagWithCode:node.gedTag] name] inContext:context];
	
	NSParameterAssert(entity);
	
	entity->_isBuildingFromGedcom = YES;
    
	if ([node xref])
		[context _setXref:[node xref] forEntity:entity];
	
	[entity addPropertiesWithGedcomNodes:node.subNodes];
    
	entity->_isBuildingFromGedcom = NO;
	
	return entity;
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
    
    return [NSString stringWithFormat:@"%@<%@: %p> (xref: %@) {\n%@%@};\n", indent, [self className], self, [_context _xrefForEntity:self], [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark Objective-C properties

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:nil
								  xref:[self.context _xrefForEntity:self]
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    NSParameterAssert([[gedcomNode xref] isEqualToString:[self.context _xrefForEntity:self]]);
    
    [super setGedcomNode:gedcomNode];
}    

- (NSString *)displayValue
{
    return [self.context _xrefForEntity:self];
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue 
                                           attributes:@{NSLinkAttributeName: [self.context _xrefForEntity:self]}];
}

- (GCObject *)rootObject
{
    return self;
}

@synthesize context = _context;

- (NSDate *)modificationDate
{
    return self[@"changeInfo"][@"modificationDate"];
}

- (void)setModificationDate:(NSDate *)modificationDate
{
    GCChangeInfoAttribute *changeInfo = self[@"changeInfo"];
    
    if (!changeInfo) {
        changeInfo = [[GCChangeInfoAttribute alloc] init];
        self[@"changeInfo"] = changeInfo;
    }
    
    [changeInfo setValue:modificationDate forKey:@"modificationDate"];
}

- (void)didChangeValueForKey:(NSString *)key
{
    if (!_isBuildingFromGedcom) {
        self.modificationDate = [NSDate date];
    }
    
    [super didChangeValueForKey:key];
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
    if (!_isBuildingFromGedcom) {
        self.modificationDate = [NSDate date];
    }
    
    [super didChange:changeKind valuesAtIndexes:indexes forKey:key];
}

@end
