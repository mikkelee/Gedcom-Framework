//
//  GCMutableArrayProxy.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCMutableOrderedSetProxy.h"

@implementation GCMutableOrderedSetProxy {
    NSMutableOrderedSet *_set;
	void (^_addBlock)(id obj);
	void (^_removeBlock)(id obj);
}

#pragma mark Initialization

- (id)init
{
	NSAssert(NO,@"You must use initWithMutableArray...");
	__builtin_unreachable();
}

- (id)initWithMutableOrderedSet:(NSMutableOrderedSet *)set 
                       addBlock:(void (^)(id obj))addBlock 
                    removeBlock:(void (^)(id obj))removeBlock
{
	self = [super init];
	
	if (self) {
		_set = set;
		_addBlock = addBlock;
		_removeBlock = removeBlock;
	}
	
	return self;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (type: %@)", [super description], _set];
}

#pragma mark Forwarding

- (id)forwardingTargetForSelector:(SEL)sel
{
	//http://www.mikeash.com/pyblog/friday-qa-2009-03-27-objective-c-message-forwarding.html
    //forward all NSMutableOrderedSet-selectors to contained set
    
	if ([_set respondsToSelector:sel]) {
        return _set;
    } else {
        return nil;
    }
}

/* is this even needed?
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector]) {
        return YES;
    } else {
        return [_set respondsToSelector:aSelector];
    }
}
*/

#pragma mark Primitive overrides

// run add/remove callbacks, then perform on contained array

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
	_addBlock(object);
	[_set insertObject:object atIndex:idx];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    _removeBlock([_set objectAtIndex:idx]);
    [_set removeObjectAtIndex:idx];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
	_addBlock(object);
    _removeBlock([_set objectAtIndex:idx]);
    [_set replaceObjectAtIndex:idx withObject:object];
}

- (void)addObject:(id)object
{
	_addBlock(object);
	[_set addObject:object];
}

- (void)addObjects:(const id [])objects count:(NSUInteger)count
{
    for (NSUInteger i = 0; i < count; i++) {
        [self addObject:objects[i]];
    }
}

- (void)addObjectsFromArray:(NSArray *)array
{
    for (id object in array) {
        [self addObject:object];
    }
}


- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    NSParameterAssert([objects count] == [indexes count]);
    
    NSUInteger index = [indexes firstIndex];
    
    for (id obj in objects) {
        [self insertObject:obj atIndex:index];
        index = [indexes indexGreaterThanIndex: index];
    }
}


- (void)setObject:(id)obj atIndex:(NSUInteger)idx
{
	_addBlock(obj);
    if([_set objectAtIndex:idx]) {
        _removeBlock([_set objectAtIndex:idx]);
    }
	[_set setObject:obj atIndex:idx];
}


- (void)replaceObjectsInRange:(NSRange)range withObjects:(const id [])objects count:(NSUInteger)count
{
    NSParameterAssert(range.length >= count);
    
    for (NSUInteger i = 0; i < count; i++) {
        [self replaceObjectAtIndex:range.location+i withObject:objects[i]];
    }
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    NSParameterAssert([objects count] == [indexes count]);
    
    NSUInteger index = [indexes firstIndex];
    
    for (id obj in objects) {
        [self replaceObjectAtIndex:index withObject:obj];
        index = [indexes indexGreaterThanIndex:index];
    }
}


- (void)removeObjectsInRange:(NSRange)range
{
    //TODO
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSUInteger index = [indexes firstIndex];
    
    while(index != NSNotFound) {
        [self removeObjectAtIndex:index];
        index = [indexes indexGreaterThanIndex:index];
    }
}

- (void)removeAllObjects
{
    for (id object in _set) {
        [self removeObject:object];
    }
}


- (void)removeObject:(id)object
{
    _removeBlock(object);
    [_set removeObject:object];
}

- (void)removeObjectsInArray:(NSArray *)array
{
    for (id obj in array) {
        [self removeObject:obj];
    }
}

@end
