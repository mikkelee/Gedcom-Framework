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
    //forward all NSMutableOrderedSet-selectors to contained array
    
	if ([_set respondsToSelector:sel]) {
        return _set;
    } else {
        return nil;
    }
}

#pragma mark Primitive overrides

// run add/remove callbacks, then perform on contained array

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
	_addBlock(anObject);
	[_set insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	_removeBlock([_set objectAtIndex:index]);
	[_set removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
	_addBlock(anObject);
	[_set addObject:anObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	_removeBlock([_set objectAtIndex:index]);
	_addBlock(anObject);
	[_set replaceObjectAtIndex:index withObject:anObject];
}

@end
