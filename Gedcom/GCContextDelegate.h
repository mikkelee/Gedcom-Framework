//
//  NSObject+GCContextDelegate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCContext.h"

@class GCEntity;
@class GCNode;
@class GCTag;
@class GCObject;

/**
 
 A set of optional methods that can be implemented by an object.
 
 If a GCContext has a delegate, it will call these if they are implemented.
 
 */
@interface NSObject (GCContextDelegate)

/** Will be called...
 
 TODO rename...
 
 @param context The context... 
 @param entity The entity.
 */
- (void)context:(GCContext *)context didReceiveActionForEntity:(GCEntity *)entity;

- (void)context:(GCContext *)context didEncounterUnknownTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object;

@end
