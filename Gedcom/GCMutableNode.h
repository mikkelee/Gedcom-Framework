//
//  GCMutableNode.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNode.h"

/**
 
 Mutable version of GCNode. They are identical except you may change the properties.
 
 */
@interface GCMutableNode : GCNode

/// @name Accessing properties

@property (readonly, weak, nonatomic) GCMutableNode *parent;

/// The tag of the receiver; may not be `nil`.
@property (nonatomic) NSString *gedTag;

/// The value of the receiver; may be `nil`.
@property (nonatomic) NSString *gedValue;

/// The xref of the receiver; may be `nil`.
@property (nonatomic) NSString *xref;

/// The line separator of the receiver; usually `\n`.
@property (nonatomic) NSString *lineSeparator;

/// A KVC-compliant ordered collection containing the subnodes of the receiver.
@property (nonatomic) NSMutableArray *mutableSubNodes;
@property (nonatomic) NSArray *subNodes;


@end