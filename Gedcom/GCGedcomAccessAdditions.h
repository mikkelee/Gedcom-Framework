//
//  GCGedcomAccessAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"
#import "GCObject.h"

@class GCNode;

@interface GCContext (GCGedcomAccessAdditions)

#pragma mark Accessing Gedcom output
/// @name Accessing Gedcom output

/// The receiver as an ordered collection of Gedcom nodes.
@property (readonly) NSArray *gedcomNodes;

/// The receiver as a Gedcom string.
@property (readonly) NSString *gedcomString;

/// The receiver's gedcomString as an NSData object using the encoding from fileEncoding
@property (readonly) NSData *gedcomData;

@end

@interface GCObject (GCGedcomAccessAdditions)

#pragma mark Accessing Gedcom output
/// @name Accessing Gedcom output

/// The receiver as a GCNode.  Setting this property will cause the receiver to interpret the node and add new properties and remove those that no longer exist.
@property (nonatomic) GCNode *gedcomNode;

/// The properties of the receiver as a collection of nodes. @see GCNode
@property (nonatomic, readonly) NSArray *subNodes;

/// The receiver as a string of Gedcom data. Setting it will interpret the string as a GCNode and set it to the receiver's gedcomNode property.
@property (nonatomic) NSString *gedcomString;

/// The receiver as an attributed string of Gedcom data.
@property (nonatomic) NSAttributedString *attributedGedcomString;

@end