//
//  GCContext+KeyValueAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext+GCKeyValueAdditions.h"

#import "GCObject+GCConvenienceAdditions.h"

#import "GCRecord.h"
#import "GCHeaderEntity.h"
#import "GCSubmissionRecord.h"
#import "GCFamilyRecord.h"
#import "GCIndividualRecord.h"
#import "GCMultimediaRecord.h"
#import "GCNoteRecord.h"
#import "GCRepositoryRecord.h"
#import "GCSourceRecord.h"
#import "GCSubmitterRecord.h"

#import "GCContextDelegate.h"

@implementation GCContext (GCKeyValueAdditions)

__strong static NSArray *_rootKeys = nil;

+ (void)load
//TODO clean up...
{
    _rootKeys = @[ @"families", @"individuals", @"multimedias", @"notes", @"repositories", @"sources", @"submitters" ];
}

- (void)setHeader:(GCHeaderEntity *)header
{
    if (_header == header) {
        return;
    }
    if (_header) {
        [_header setValue:nil forKey:@"context"];
    }
    [header setValue:self forKey:@"context"];
    _header = header;
}

- (GCHeaderEntity *)header
{
    return _header;
}

- (void)setSubmission:(GCSubmissionRecord *)submission
{
    if (_submission == submission) {
        return;
    }
    if (_submission) {
        [_submission setValue:nil forKey:@"context"];
    }
    [submission setValue:self forKey:@"context"];
    _submission = submission;
}

- (GCSubmissionRecord *)submission
{
    return _submission;
}

- (NSArray *)families
{
    return _families;
}

- (NSArray *)individuals
{
    return _individuals;
}

- (NSArray *)multimedias
{
    return _multimedias;
}

- (NSArray *)notes
{
    return _notes;
}

- (NSArray *)repositories
{
    return _repositories;
}

- (NSArray *)sources
{
    return _sources;
}

- (NSArray *)submitters
{
    return _submitters;
}

#pragma mark Accessing entities

- (NSArray *)entities
{
    NSMutableArray *entities = [NSMutableArray array];
    
    if (self.header) {
        [entities addObject:self.header];
    }
    if (self.submission) {
        [entities addObject:self.submission];
    }
    
    for (NSString *entityType in _rootKeys) {
        [entities addObjectsFromArray:[super valueForKey:entityType]];
    }
    
    [entities addObjectsFromArray:_customEntities];
    
	return [entities copy];
}

- (NSMutableArray *)mutableEntities
{
    return [self mutableArrayValueForKey:@"entities"];
}

- (NSUInteger)countOfEntities
{
    return [self.entities count];
}

- (void)_addEntity:(GCEntity *)entity
{
	NSParameterAssert([entity isKindOfClass:[GCEntity class]]);
    
    if (entity.context == self) {
        return;
    }
    
    GCContext *oldContext = entity.context;
    
    [oldContext.mutableEntities removeObject:entity];
    
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        self.header = (GCHeaderEntity *)entity;
    } else if ([entity isKindOfClass:[GCSubmissionRecord class]]) {
        self.submission = (GCSubmissionRecord *)entity;
    } else  {
        @synchronized (self) {
            if ([_rootKeys containsObject:entity.gedTag.pluralName]) {
                [[self mutableArrayValueForKey:entity.gedTag.pluralName] addObject:entity];
            } else {
                [entity setValue:self forKey:@"context"];
                [_customEntities addObject:entity];
            }
        }
    }
    
    NSParameterAssert(entity.context == self);
    
    if (oldContext != self) {
        for (GCEntity *relatedEntity in entity.relatedEntities) {
            [self _addEntity:relatedEntity];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:[self.entities count]];
        }
    });
}

- (void)insertObject:(GCEntity *)entity inEntitiesAtIndex:(NSUInteger)index
{
    [self _addEntity:entity];
}

- (void)removeObjectFromEntitiesAtIndex:(NSUInteger)index
{
    GCEntity *entity = self.entities[index];
    
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        if (self.header == entity) {
            self.header = nil;
        }
    } else if ([entity isKindOfClass:[GCSubmissionRecord class]]) {
        if (self.submission == entity) {
            self.submission = nil;
        }
    } else if ([entity isKindOfClass:[GCEntity class]]) {
        @synchronized (self) {
            if ([_rootKeys containsObject:entity.gedTag.pluralName]) {
                [[self mutableArrayValueForKey:entity.gedTag.pluralName] removeObject:entity];
            } else {
                [entity setValue:nil forKey:@"context"];
                [_customEntities removeObject:entity];
            }
        }
    } else {
        NSAssert(NO, @"Unknown class: %@", entity);
    }
    
    NSParameterAssert(!entity.context);
    
    // TODO handle xrefs, remove self as ctx param, and any relationships...
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:self.countOfEntities];
        }
    });
}



- (NSMutableArray *)mutableFamilies {
    return [self mutableArrayValueForKey:@"families"];
}

- (NSUInteger)countOfFamilies {
	return [_families count];
}

- (id)objectInFamiliesAtIndex:(NSUInteger)index {
    return [_families objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inFamiliesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCFamilyRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_families insertObject:obj atIndex:index];
}

- (void)removeObjectFromFamiliesAtIndex:(NSUInteger)index {
    [_families[index] setValue:nil forKey:@"context"];
    [_families removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableIndividuals {
    return [self mutableArrayValueForKey:@"individuals"];
}

- (NSUInteger)countOfIndividuals {
	return [_individuals count];
}

- (id)objectInIndividualsAtIndex:(NSUInteger)index {
    return [_individuals objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inIndividualsAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCIndividualRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_individuals insertObject:obj atIndex:index];
}

- (void)removeObjectFromIndividualsAtIndex:(NSUInteger)index {
    [_individuals[index] setValue:nil forKey:@"context"];
    [_individuals removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableMultimedias {
    return [self mutableArrayValueForKey:@"multimedias"];
}

- (NSUInteger)countOfMultimedias {
	return [_multimedias count];
}

- (id)objectInMultimediasAtIndex:(NSUInteger)index {
    return [_multimedias objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inMultimediasAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCMultimediaRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_multimedias insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediasAtIndex:(NSUInteger)index {
    [_multimedias[index] setValue:nil forKey:@"context"];
    [_multimedias removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableNotes {
    return [self mutableArrayValueForKey:@"notes"];
}

- (NSUInteger)countOfNotes {
	return [_notes count];
}

- (id)objectInNotesAtIndex:(NSUInteger)index {
    return [_notes objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inNotesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCNoteRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_notes insertObject:obj atIndex:index];
}

- (void)removeObjectFromNotesAtIndex:(NSUInteger)index {
    [_notes[index] setValue:nil forKey:@"context"];
    [_notes removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableRepositories {
    return [self mutableArrayValueForKey:@"repositories"];
}

- (NSUInteger)countOfRepositories {
	return [_repositories count];
}

- (id)objectInRepositoriesAtIndex:(NSUInteger)index {
    return [_repositories objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inRepositoriesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCRepositoryRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_repositories insertObject:obj atIndex:index];
}

- (void)removeObjectFromRepositoriesAtIndex:(NSUInteger)index {
    [_repositories[index] setValue:nil forKey:@"context"];
    [_repositories removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableSources {
    return [self mutableArrayValueForKey:@"sources"];
}

- (NSUInteger)countOfSources {
	return [_sources count];
}

- (id)objectInSourcesAtIndex:(NSUInteger)index {
    return [_sources objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inSourcesAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSourceRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_sources insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourcesAtIndex:(NSUInteger)index {
    [_sources[index] setValue:nil forKey:@"context"];
    [_sources removeObjectAtIndex:index];
}



- (NSMutableArray *)mutableSubmitters {
    return [self mutableArrayValueForKey:@"submitters"];
}

- (NSUInteger)countOfSubmitters {
	return [_submitters count];
}

- (id)objectInSubmittersAtIndex:(NSUInteger)index {
    return [_submitters objectAtIndex:index];
}

- (void)insertObject:(GCEntity *)obj inSubmittersAtIndex:(NSUInteger)index {
	NSParameterAssert([obj isKindOfClass:[GCSubmitterRecord class]]);
    if (obj.context == self) {
        return;
    }
    [obj setValue:self forKey:@"context"];
    [_submitters insertObject:obj atIndex:index];
}

- (void)removeObjectFromSubmittersAtIndex:(NSUInteger)index {
    [_submitters[index] setValue:nil forKey:@"context"];
    [_submitters removeObjectAtIndex:index];
}

#pragma mark Subscript accessors

- (id)objectForKeyedSubscript:(id)key
{
    return [super valueForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key
{
    return [self setValue:object forKey:(NSString *)key];
}

@end
