//
//  GCObjectProxy.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 03/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObjectProxy.h"

#import "GCObject_internal.h"
#import "GCGedcomLoadingAdditions_internal.h"

@implementation GCObjectProxy {
    GCObject *_object;
}

- (instancetype)initWitBlock:(GCObject *(^)())block
{
    if (self) {
        self->_object = block();
    }
    
    return self;
}

- (Class)class
{
    return [_object class];
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [_object isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [_object isMemberOfClass:aClass];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [_object _waitUntilDoneBuildingFromGedcom];
    
    [invocation invokeWithTarget:_object];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_object methodSignatureForSelector:sel];
}

- (GCContext *)context
{
    return _object.context;
}

- (GCObject *)rootObject
{
    return _object.rootObject;
}

@end
