//
//  GCMutableArrayProxy.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 A proxy object that will issue callbacks when objects are added or removed. Used internally to maintain integrity in two-way relationships (for instance a GCObject's properties and their describedObject).
 
 Responds to all NSMutableOrderedSet selectors and can be used as such.
 
 */
@interface GCMutableOrderedSetProxy : NSProxy

#pragma mark Initialization

/** Initializes and returns a proxy object with the provided set and callback blocks.
 
 @param set A set of objects.
 @param addBlock A block that will be called when objects are added to the proxy.
 @param removeBlock A block that will be called when objects are removed from the proxy.
 @return A new proxy object.
 */
- (id)initWithMutableOrderedSet:(NSMutableOrderedSet *)set addBlock:(void (^)(id obj))addBlock removeBlock:(void (^)(id obj))removeBlock;

@end
