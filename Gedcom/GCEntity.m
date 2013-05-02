//
//  GCEntity.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"

#import "GCContext_internal.h"
#import "GCContext+GCTransactionAdditions.h"
#import "GCTagAccessAdditions.h"

@implementation GCEntity {
    __weak GCContext *_context;
}

#pragma mark Initialization

- (instancetype)initInContext:(GCContext *)context
{
    GCParameterAssert(context);
    
    self = [super init];
    
    if (self) {
        _isBuildingFromGedcom = NO;
        [context _addEntity:self];
        NSParameterAssert(self.context == context);
    }
    
    return self;
}

#pragma mark NSCoding conformance

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
        if (self.takesValue) {
            _value = [aDecoder decodeObjectForKey:@"value"];
        }
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeConditionalObject:_context forKey:@"context"];
    if (self.takesValue) {
        [aCoder encodeObject:_value forKey:@"value"];
    }
}

#pragma mark Description

//COV_NF_START
- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSString *indent = @"";
    for (NSUInteger i = 0; i < level; i++) {
        indent = [NSString stringWithFormat:@"%@%@", indent, @"  "];
    }
    
    return [NSString stringWithFormat:@"%@<%@: %p> {\n%@%@};\n", indent, [self className], self, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark Objective-C properties

- (GCObject *)rootObject
{
    return self;
}

- (NSUndoManager *)undoManager
{
    return self.context.undoManager;
}

@synthesize context = _context;

@synthesize value = _value;

- (void)setValue:(GCString *)value
{
    NSParameterAssert(self.takesValue);
    
    _value = value;
}

@end