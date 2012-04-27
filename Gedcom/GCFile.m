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

#import "GCMutableOrderedSetProxy.h"

@interface GCTrailer : NSObject
@end
@implementation GCTrailer
@end

@implementation GCFile {
	GCContext *_context;
}

#pragma mark Initialization

- (id)initWithContext:(GCContext *)context gedcomNodes:(NSArray *)nodes;
{
	self = [super init];
	
	if (self) {
		_context = context;
		_records = [NSMutableArray arrayWithCapacity:[nodes count]];
		
		for (GCNode *node in nodes) {
            GCTag *tag = [GCTag rootTagWithCode:[node gedTag]];
            Class objectClass = [tag objectClass];
            
            if ([objectClass isEqual:[GCHeader class]]) {
                if (_head) {
                    NSLog(@"Multiple headers!?");
                }
                _head = [GCHeader headerWithGedcomNode:node inContext:context];
            } else if ([objectClass isEqual:[GCEntity class]]) {
                [_records addObject:[GCEntity entityWithGedcomNode:node inContext:context]];
            } else if ([objectClass isEqual:[GCTrailer class]]) {
                continue; //ignore trailer... 
            } else {
                NSLog(@"Shouldn't happen! %@ unknown class: %@", node, objectClass);
            }
		}
	}
	
	return self;
}

- (id)initWithHeader:(GCHeader *)header entities:(NSArray *)entities
{
    self = [super init];
    
    if (self) {
        _head = header;
        _records = [NSMutableOrderedSet orderedSetWithCapacity:[entities count]];
        
        for (GCEntity *entity in entities) {
            NSParameterAssert(_context == nil || _context == [entity context]);
            
            [_records addObject:entity];
        }
    }
    
    return self;
}


#pragma mark Convenience constructor

+ (id)fileWithGedcomNodes:(NSArray *)nodes
{
	return [[self alloc] initWithContext:[GCContext context] gedcomNodes:nodes];
}

#pragma mark Record access

- (void)addRecord:(GCEntity *)record
{
    [_records addObject:record];
}

- (void)removeRecord:(GCEntity *)record
{
    [_records removeObject:record];
}

#pragma mark Objective-C properties

@synthesize head = _head;
@synthesize submission = _submission;
@synthesize records = _records;

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[_records count]+2];
	
	[nodes addObject:[_head gedcomNode]];
    
    if (_submission) {
        [nodes addObject:[_submission gedcomNode]];
    }
	
	for (id record in _records) {
		[nodes addObject:[record gedcomNode]];
	}
	
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

@end

@implementation GCFile (GCConvenienceMethods)

- (id)recordsOfType:(NSString *)type
{
	NSMutableOrderedSet *records = [NSMutableOrderedSet orderedSet];
	
	for (GCEntity *record in _records) {
		if ([[record type] isEqualToString:type]) {
			[records addObject:record];
		}
	}
	
	return [[GCMutableOrderedSetProxy alloc] initWithMutableOrderedSet:records
                                                              addBlock:^(id obj) {
                                                                  [self addRecord:obj];
                                                              }
                                                           removeBlock:^(id obj) {
                                                               [self removeRecord:obj];
                                                           }];
}

- (id)families
{
	return [self recordsOfType:@"Family record"];
}

- (id)individuals
{
	return [self recordsOfType:@"Individual record"];
}

- (id)multimediaObjects
{
	return [self recordsOfType:@"Multimedia record"];
}

- (id)notes
{
	return [self recordsOfType:@"Note record"];
}

- (id)repositories
{
	return [self recordsOfType:@"Repository record"];
}

- (id)sources
{
	return [self recordsOfType:@"Source record"];
}

- (id)submitters 
{
	return [self recordsOfType:@"Submitter record"];
}

@end
