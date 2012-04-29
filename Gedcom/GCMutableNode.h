//
//  GCMutableNode.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNode.h"

/**
 
 Mutable version of GCNode.
 
 */
@interface GCMutableNode : GCNode

/// @name Accessing subnodes

/** Adds a subnode at the end of the receiver's collection of subnodes.
 
 The parent of the subnode will be updated to reflect the receiver.
 
 @param node A node.
 */
- (void)addSubNode: (GCMutableNode *) node;

/** Removes a subnode from the receiver's collection of subnodes.
 
 The parent of the subnode will be set to `nil`.
 
 @param node A node.
 */
- (void)removeSubNode: (GCMutableNode *) node;

/** Adds each node in turn using addSubNode:
 
 @param nodes An array of nodes.
 */
- (void)addSubNodes: (NSArray *) nodes;

/// @name Accessing properties

/// The tag of the receiver; may not be `nil`.
@property NSString *gedTag;

/// The value of the receiver; may be `nil`.
@property NSString *gedValue;

/// The xref of the receiver; may be `nil`.
@property NSString *xref;

/// The line separator of the receiver; usually `\n`.
@property NSString *lineSeparator;

/// An ordered collection containing the subnodes of the receiver; may not be `nil`.
@property NSOrderedSet *subNodes;

@end
