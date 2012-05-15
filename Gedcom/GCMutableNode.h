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

/// @name Accessing properties

/// The tag of the receiver; may not be `nil`.
@property NSString *gedTag;

/// The value of the receiver; may be `nil`.
@property NSString *gedValue;

/// The xref of the receiver; may be `nil`.
@property NSString *xref;

/// The line separator of the receiver; usually `\n`.
@property NSString *lineSeparator;

/// A KVC-compliant uniquing ordered collection containing the subnodes of the receiver.
@property (readonly) NSMutableOrderedSet *subNodes;

@end