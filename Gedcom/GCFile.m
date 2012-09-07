//
//  GCFile.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCFile.h"
#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCContext.h"

#import "GCHeader.h"
#import "GCEntity.h"

#import "GCObjects_generated.h"

#import "GCFileDelegate.h"

@interface GCTrailer : NSObject //empty class to match trailer objects
@end
@implementation GCTrailer
@end

@implementation GCFile {
	GCContext *_context;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    if (self) {
        _context = [GCContext context];
		_entities = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
		_entities = [NSMutableArray arrayWithCapacity:[nodes count]];
		
        [self parseNodes:nodes];
	}
	
	return self;
}

- (id)initWithHeader:(GCHeader *)header entities:(NSArray *)entities
{
    self = [super init];
    
    if (self) {
        _header = header;
        _context = [header context];
        
        _entities = [NSMutableOrderedSet orderedSetWithCapacity:[entities count]];
        
        for (GCEntity *entity in entities) {
            NSParameterAssert(_context == [entity context]);
            
            [_entities addObject:entity];
        }
    }
    
    return self;
}


#pragma mark Convenience constructor

+ (id)fileWithGedcomNodes:(NSArray *)nodes
{
	return [[self alloc] initWithContext:[GCContext context] gedcomNodes:nodes];
}

#pragma mark Node access

- (void)parseNodes:(NSArray *)nodes
{
    NSParameterAssert([_entities count] == 0);
    
    [nodes enumerateObjectsWithOptions:(kNilOptions) usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GCNode *node = (GCNode *)obj;
        
        GCTag *tag = [GCTag rootTagWithCode:[node gedTag]];
        Class objectClass = [tag objectClass];
        
        if ([objectClass isSubclassOfClass:[GCHeader class]]) {
            if (_header) {
                NSLog(@"Multiple headers!?");
            }
            _header = [GCHeader headerWithGedcomNode:node inContext:_context];
        } else if ([objectClass isSubclassOfClass:[GCSubmissionEntity class]]) {
            _submission = [GCEntity entityWithGedcomNode:node inContext:_context];
        } else if ([objectClass isSubclassOfClass:[GCEntity class]]) {
            [_entities addObject:[GCEntity entityWithGedcomNode:node inContext:_context]];
        } else if ([objectClass isSubclassOfClass:[GCTrailer class]]) {
            *stop = YES;
            return;
        } else {
            NSLog(@"Shouldn't happen! %@ unknown class: %@", node, objectClass);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
                [_delegate file:self updatedEntityCount:[_entities count]];
            }
        });
    }];
    
    NSInteger count = [_entities count];
    if (_header)
        count++;
    if (_submission)
        count++;
    count++; //trailer
    
    NSParameterAssert(count == [nodes count]);
    
    if (_delegate && [_delegate respondsToSelector:@selector(file:didFinishWithEntityCount:)]) {
        [_delegate file:self didFinishWithEntityCount:[_entities count]];
    }
}

#pragma mark Entity access

- (void)addEntity:(GCEntity *)entity
{
    NSParameterAssert([[entity context] isEqual:_context]);
    
    [_entities addObject:entity];
    /*
    if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
        [_delegate file:self updatedEntityCount:[_entities count]];
    }*/
}

- (void)removeEntity:(GCEntity *)entity
{
    [_entities removeObject:entity];
    /*
    if (_delegate && [_delegate respondsToSelector:@selector(file:updatedEntityCount:)]) {
        [_delegate file:self updatedEntityCount:[_entities count]];
    }*/
}

#pragma mark Equality

- (BOOL)isEqualTo:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [[self gedcomString] isEqualToString:[object gedcomString]];
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        _context = [aDecoder decodeObjectForKey:@"context"];
        _header = [aDecoder decodeObjectForKey:@"header"];
        _submission = [aDecoder decodeObjectForKey:@"submission"];
        _entities = [aDecoder decodeObjectForKey:@"entities"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_context forKey:@"context"];
    [aCoder encodeObject:_header forKey:@"header"];
    [aCoder encodeObject:_submission forKey:@"submission"];
    [aCoder encodeObject:_entities forKey:@"entities"];
}

#pragma mark Objective-C properties

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[_entities count]+2];
	
	[nodes addObject:[_header gedcomNode]];
    
    if (_submission) {
        [nodes addObject:[_submission gedcomNode]];
    }
	
	for (id entity in _entities) {
		[nodes addObject:[entity gedcomNode]];
	}
	
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

- (NSString *)gedcomString
{
    NSMutableArray *gedcomStrings = [NSMutableArray array];
    
    for (GCNode *node in [self gedcomNodes]) {
        [gedcomStrings addObjectsFromArray:[node gedcomLines]];
    }
    
    return [gedcomStrings componentsJoinedByString:@"\n"];
}

@end

@implementation GCFile (GCConvenienceMethods)

- (id)entitiesPassingTest:(BOOL (^)(id obj))block
{
	NSMutableOrderedSet *entities = [NSMutableOrderedSet orderedSet];
	
    NSIndexSet *indexes = [_entities indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    NSUInteger idx = [indexes firstIndex];
    
    while(idx != NSNotFound) {
		[entities addObject:[_entities objectAtIndex:idx]];
        idx = [indexes indexGreaterThanIndex:idx];
    }
	
    
    return entities; //TODO KVC
}

- (id)entitiesOfType:(NSString *)type
{
    return [self entitiesPassingTest:^BOOL(id obj) {
        return [[(GCEntity *)obj type] isEqualToString:type];
    }];
}

- (id)families
{
	return [self entitiesOfType:@"family"];
}

- (id)individuals
{
	return [self entitiesOfType:@"individual"];
}

- (id)multimediaObjects
{
	return [self entitiesOfType:@"multimedia"];
}

- (id)notes
{
	return [self entitiesOfType:@"note"];
}

- (id)repositories
{
	return [self entitiesOfType:@"repository"];
}

- (id)sources
{
	return [self entitiesOfType:@"source"];
}

- (id)submitters 
{
	return [self entitiesOfType:@"submitter"];
}

- (GCContext *)context
{
    return _context;
}

@end

@implementation GCFile (GCValidationMethods)

- (BOOL)validateFile:(NSError *__autoreleasing *)error
{
    if (![_header validateObject:error]) {
        return NO;
    }
    
    if (_submission && ![_submission validateObject:error]) {
        return NO;
    }
    
    for (GCEntity *entity in _entities) {
        if (![entity validateObject:error]) {
            return NO;
        }
    }
    
    return YES;
}

@end