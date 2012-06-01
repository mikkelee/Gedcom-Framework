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

#import "GCContext.h"

#import "GCChangedDateFormatter.h"

@interface GCEntity ()

@property NSDate *lastModified;

@end

@implementation GCEntity {
    GCContext *_context;
}

#pragma mark Initialization

- (id)initWithType:(NSString *)type inContext:(GCContext *)context
{
    NSParameterAssert(context);
    
    self = [super initWithType:type];
    
    if (self) {
		_context = context;
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
    GCEntity *entity = [self entityWithType:[[GCTag rootTagWithCode:[node gedTag]] name] inContext:context];
    
	[context setXref:[node xref] forEntity:entity];
	dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        //TODO clean up this part:
        __block GCNode *changeNode = nil;
        
        [[node subNodes] enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GCNode *subNode = (GCNode *)obj;
            if ([[subNode gedTag] isEqualToString:@"CHAN"]) {
                changeNode = subNode;
                *stop = YES;
            }
        }];
        
        NSMutableOrderedSet *subNodesWithoutChan = [[node subNodes] mutableCopy];
        
        [subNodesWithoutChan removeObject:changeNode];
        
        [entity addPropertiesWithGedcomNodes:subNodesWithoutChan];
        
        if (changeNode) {
            [entity setLastModified:[[GCChangedDateFormatter sharedFormatter] dateWithNode:changeNode]];
        } else {
            [entity setLastModified:nil];
        }
    });
    
    return entity;
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if ([self type] != [(GCProperty *)other type]) {
        return [[self type] compare:[(GCProperty *)other type]];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
        _lastModified = [aDecoder decodeObjectForKey:@"lastModified"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_context forKey:@"context"];
    [aCoder encodeObject:_lastModified forKey:@"lastModified"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (properties: %@)", [super description], [self valueForKey:@"properties"]];
}
//COV_NF_END

#pragma mark Objective-C properties

- (NSOrderedSet *)subNodes
{
    NSMutableOrderedSet *subNodes = [[super subNodes] mutableCopy];
    
    if (_lastModified) {
        [subNodes addObject:[[GCChangedDateFormatter sharedFormatter] nodeWithDate:_lastModified]];
    }
    
    return subNodes;
}

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[[self gedTag] code]
								 value:nil
								  xref:[[self context] xrefForEntity:self]
							  subNodes:[self subNodes]];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    NSParameterAssert([[gedcomNode xref] isEqualToString:[[self context] xrefForEntity:self]]);
    
    [super setGedcomNode:gedcomNode];
}    

- (NSString *)displayValue
{
    return [[self context] xrefForEntity:self];
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:[self displayValue] 
                                           attributes:[NSDictionary dictionaryWithObject:[[self context] xrefForEntity:self]
                                                                                  forKey:NSLinkAttributeName]];
}

@synthesize context = _context;

@synthesize lastModified = _lastModified;

- (void)didChangeValueForKey:(NSString *)key
{
    [self setLastModified:[NSDate date]];
    [super didChangeValueForKey:key];
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
    [self setLastModified:[NSDate date]];
    [super didChange:changeKind valuesAtIndexes:indexes forKey:key];
}

@end
