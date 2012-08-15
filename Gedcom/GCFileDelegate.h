//
//  GCFileDelegate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 13/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 A set of optional methods that can be implemented by an object.
 
 If a GCFile has a delegate, it will call these if they are implemented.
 
 */
@interface NSObject (GCFileDelegate)

/** Will be called when a GCFile's entity count changes during parsing.
 
 @param file The file whose entity count changed.
 @param entityCount The new count.
 */
- (void)file:(GCFile *)file updatedEntityCount:(NSInteger)entityCount;

/** Will be called when a GCFile's is done parsing.
 
 @param file The file whose entity count changed.
 @param entityCount The new count.
 */
- (void)file:(GCFile *)file didFinishWithEntityCount:(NSInteger)entityCount;

@end
