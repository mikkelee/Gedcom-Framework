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
        [_context xrefForEntity:self];
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
    
	[context storeXref:[node xref] forEntity:entity];
	
    for (GCNode *subNode in [node subNodes]) {
        if ([[subNode gedTag] isEqualToString:@"CHAN"]) {
            [entity setLastModified:[[GCChangedDateFormatter sharedFormatter] dateWithNode:subNode]];
        } else {
            [entity addPropertyWithGedcomNode:subNode];
        }
    }
    
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

@synthesize context = _context;

@synthesize lastModified = _lastModified;

@end
