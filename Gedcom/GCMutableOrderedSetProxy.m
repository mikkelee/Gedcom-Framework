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

- (id)initWithMutableOrderedSet:(NSMutableOrderedSet *)set 
                       addBlock:(void (^)(id obj))addBlock 
                    removeBlock:(void (^)(id obj))removeBlock
{
    NSParameterAssert(set);
    
	_set = set;
	_addBlock = addBlock;
	_removeBlock = removeBlock;
	
	return self;
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (type: %@)", [super description], _set];
}
//COV_NF_END

#pragma mark Forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    //NSLog(@"selector: %@", NSStringFromSelector(aSelector));
    
    return [NSMutableOrderedSet instanceMethodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)invocation
{
    //NSLog(@"invocation: %@", invocation);
    
    //TODO could probably run _addBlock & _removeBlock here with some state-checking code and get rid of the overrides below.
    
    [invocation setTarget:_set];
    [invocation invoke];
    return;
}

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
    
    NSUInteger idx = [indexes firstIndex];
    
    for (id obj in objects) {
        [self insertObject:obj atIndex:idx];
        idx = [indexes indexGreaterThanIndex: idx];
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
    
    NSUInteger idx = [indexes firstIndex];
    
    for (id obj in objects) {
        [self replaceObjectAtIndex:idx withObject:obj];
        idx = [indexes indexGreaterThanIndex:idx];
    }
}


- (void)removeObjectsInRange:(NSRange)range
{
    for (NSUInteger idx = range.location; idx <= range.length; idx++) {
        [self removeObjectAtIndex:idx];
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSUInteger idx = [indexes firstIndex];
    
    while(idx != NSNotFound) {
        [self removeObjectAtIndex:idx];
        idx = [indexes indexGreaterThanIndex:idx];
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
