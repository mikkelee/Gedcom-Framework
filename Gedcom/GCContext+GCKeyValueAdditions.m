//
//  GCContext+KeyValueAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext_internal.h"

#import "GCHeaderEntity.h"
#import "GCSubmissionEntity.h"
#import "GCFamilyEntity.h"
#import "GCIndividualEntity.h"
#import "GCMultimediaEntity.h"
#import "GCNoteEntity.h"
#import "GCRepositoryEntity.h"
#import "GCSourceEntity.h"
#import "GCSubmitterEntity.h"

@implementation GCContext (GCKeyValueAdditions)

__strong static NSArray *_rootKeys = nil;

+ (void)load
//TODO clean up...
{
    _rootKeys = @[ @"families", @"individuals", @"multimedias", @"notes", @"repositories", @"sources", @"submitters" ];
}

- (void)setHeader:(GCHeaderEntity *)header
{
    _header = header;
}

- (GCHeaderEntity *)header
{
    return _header;
}

- (GCSubmissionEntity *)submission
{
    return _submission;
}

- (void)setSubmission:(GCSubmissionEntity *)submission
{
    _submission = submission;
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
    NSUInteger count = 0;
    
    if (self.header)
        count++;
    if (self.submission)
        count++;
    
    @synchronized (self) {
        for (NSString *key in _rootKeys) {
            count += [[self valueForKey:key] count];
        }
    }
    
    count++; //trailer
    
    return count;
}

- (void)_addEntity:(GCEntity *)entity
{
	NSParameterAssert([entity isKindOfClass:[GCEntity class]]);
    
    [entity setValue:self forKey:@"context"]; //TODO
    
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        self.header = (GCHeaderEntity *)entity;
    } else if ([entity isKindOfClass:[GCSubmissionEntity class]]) {
        self.submission = (GCSubmissionEntity *)entity;
    } else  {
        @synchronized (self) {
            if ([_rootKeys containsObject:entity.gedTag.pluralName]) {
                [[self mutableArrayValueForKey:entity.gedTag.pluralName] addObject:entity];
            } else {
                [_customEntities addObject:entity];
                NSLog(@"entity");
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
            [_delegate context:self didUpdateEntityCount:self.countOfEntities];
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
    
    NSParameterAssert(entity.context == self);
    
    if ([entity isKindOfClass:[GCHeaderEntity class]]) {
        if (_header == entity) {
            self.header = nil;
        }
    } else if ([entity isKindOfClass:[GCSubmissionEntity class]]) {
        if (_submission == entity) {
            self.submission = nil;
        }
    } else if ([entity isKindOfClass:[GCEntity class]]) {
        @synchronized (self) {
            if ([_rootKeys containsObject:entity.gedTag.pluralName]) {
                [[self mutableArrayValueForKey:entity.gedTag.pluralName] removeObject:entity];
            } else {
                [_customEntities removeObject:entity];
            }
        }
    } else {
        NSAssert(NO, @"Unknown class: %@", entity);
    }
    
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
	NSParameterAssert([obj isKindOfClass:[GCFamilyEntity class]]);
    NSParameterAssert(obj.context == self);
    [_families insertObject:obj atIndex:index];
}

- (void)removeObjectFromFamiliesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_families[index]).context);
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
	NSParameterAssert([obj isKindOfClass:[GCIndividualEntity class]]);
    NSParameterAssert(obj.context == self);
    [_individuals insertObject:obj atIndex:index];
}

- (void)removeObjectFromIndividualsAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_individuals[index]).context);
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
	NSParameterAssert([obj isKindOfClass:[GCMultimediaEntity class]]);
    NSParameterAssert(obj.context == self);
    [_multimedias insertObject:obj atIndex:index];
}

- (void)removeObjectFromMultimediasAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_multimedias[index]).context);
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
	NSParameterAssert([obj isKindOfClass:[GCNoteEntity class]]);
    NSParameterAssert(obj.context == self);
    [_notes insertObject:obj atIndex:index];
}

- (void)removeObjectFromNotesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_notes[index]).context);
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
	NSParameterAssert([obj isKindOfClass:[GCRepositoryEntity class]]);
    NSParameterAssert(obj.context == self);
    [_repositories insertObject:obj atIndex:index];
}

- (void)removeObjectFromRepositoriesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_repositories[index]).context);
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
	NSParameterAssert([obj isKindOfClass:[GCSourceEntity class]]);
    NSParameterAssert(obj.context == self);
    [_sources insertObject:obj atIndex:index];
}

- (void)removeObjectFromSourcesAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_sources[index]).context);
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
	NSParameterAssert([obj isKindOfClass:[GCSubmitterEntity class]]);
    NSParameterAssert(obj.context == self);
    [_submitters insertObject:obj atIndex:index];
}

- (void)removeObjectFromSubmittersAtIndex:(NSUInteger)index {
    NSParameterAssert(!((GCEntity *)_submitters[index]).context);
    [_submitters removeObjectAtIndex:index];
}

@end
