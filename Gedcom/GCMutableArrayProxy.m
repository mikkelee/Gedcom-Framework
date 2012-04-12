//
//  GCMutableArrayProxy.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCMutableArrayProxy.h"

@implementation GCMutableArrayProxy {
	NSMutableArray *_array;
	void (^_addBlock)(id obj);
	void (^_removeBlock)(id obj);
}

#pragma mark Initialization

- (id)init
{
	NSAssert(NO,@"You must use initWithMutableArray...");
	__builtin_unreachable();
}

- (id)initWithMutableArray:(NSMutableArray *)array 
                  addBlock:(void (^)(id obj))addBlock 
               removeBlock:(void (^)(id obj))removeBlock
{
	self = [super init];
	
	if (self) {
		_array = array;
		_addBlock = addBlock;
		_removeBlock = removeBlock;
	}
	
	return self;
}

#pragma mark Forwarding

- (id)forwardingTargetForSelector:(SEL)sel
{
	//http://www.mikeash.com/pyblog/friday-qa-2009-03-27-objective-c-message-forwarding.html
	
	return _array; //forward all unknown selectors to contained array
}

#pragma mark Primitive overrides:

// run add/remove callbacks, then perform on contained array

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
	_addBlock(anObject);
	[_array insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	_removeBlock([_array objectAtIndex:index]);
	[_array removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
	_addBlock(anObject);
	[_array addObject:anObject];
}

- (void)removeLastObject
{
	_removeBlock([_array lastObject]);
	[_array removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	_removeBlock([_array objectAtIndex:index]);
	_addBlock(anObject);
	[_array replaceObjectAtIndex:index withObject:anObject];
}

@end
