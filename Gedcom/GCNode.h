//
//  GCNode.h
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 Nodes are structures representing Gedcom data as nested objects with accessors for tags, values, xrefs, etc.
 
 Nodes are immutable, but see also GCMutableNode.
 
 */
@interface GCNode : NSObject <NSCopying, NSCoding, NSMutableCopying>

#pragma mark Initialization

/// @name Creating and initializing nodes

/** Initializes and returns a node with the specified properties.
 
 @param tag A letter string such as @"INDI" or @"NOTE"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param value An optional value.
 @param xref An optional xref.
 @param subNodes An ordered collection of nodes. If `nil`, the node will create an empty collection.
 @return A new node.
 */
- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(id)subNodes;

#pragma mark Convenience constructors

/** Given a string of Gedcom data, will create an array of the nodes at level 0 of the data. Each node will further have subnodes as indicated by their level in the data.
 
 @param gedString A string of Gedcom data
 @return An array of nodes.
 */
+ (NSArray *)arrayOfNodesFromString:(NSString*) gedString;

#pragma mark Subscript accessors

- (id)objectForKeyedSubscript:(id)key;

#pragma mark Gedcom output

/// @name Gedcom output

/// The receiver including its subnodes as a string.
@property (readonly) NSString *gedcomString;

/** The receiver including its subnodes as an attributed string.
 
 The string will have substrings marked with one of the following attributes: 
 
 GCLevelAttributeName,
 GCXrefAttributeName,
 GCTagAttributeName,
 GCValueAttributeName, or
 GCLinkAttributeName
 
 */
@property (readonly) NSAttributedString *attributedGedcomString;

/// The receiver including its subnodes as an array of strings.
@property (readonly) NSArray *gedcomLines;

#pragma mark Comparison

/** Compares the receiver to another node.
 
 Equivalence is determined by comparing the tag, xref and value of the nodes, and comparing all subNodes in turn. The order of subNodes is disregarded.
 
 Returns `YES` if the nodes are equivalent, otherwise `NO`.
 
 @param other Another GCNode object.
 @return A BOOL indicating equivalence.
 */
- (BOOL)isEquivalentTo:(GCNode *)other;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The parent node of the receiver; will be `nil` for root nodes.
@property (weak, readonly) GCNode *parent;

/// The tag of the receiver; may not be `nil`.
@property (readonly) NSString *gedTag;

/// The value of the receiver; may be `nil`.
@property (readonly) NSString *gedValue;

/// `TRUE` the value is non-nil and starts and ends with a `@`. Otherwise `NO`
@property (readonly) BOOL valueIsXref;

/// The xref of the receiver; may be `nil`.
@property (readonly) NSString *xref;

/// The line separator of the receiver; usually `\n`.
@property (readonly) NSString *lineSeparator;

/// An ordered uniquing collection containing the subnodes of the receiver; may not be `nil`.
@property (readonly) NSArray *subNodes;

/// A uniquing collection containing the gedTags for all subNodes of the receiver.
@property (readonly) NSSet *allSubTags;

@end

@interface GCNode (GCConvenienceMethods)

/// @name Creating and initializing nodes

/** Returns a node with the specified properties.
 
 @param tag A three or four letter string such as @"INDI" or @"FAM"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param value An optional value.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value;

/** Returns a node with the specified properties.
 
 @param tag A three or four letter string such as @"INDI" or @"FAM"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param xref An optional xref.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref;

/** Returns a node with the specified properties.
 
 @param tag A three or four letter string such as @"INDI" or @"FAM"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param value An optional value.
 @param subNodes An ordered collection of nodes. If `nil`, the node will create an empty collection.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value subNodes:(id)subNodes;

/** Returns a node with the specified properties.
 
 @param tag A three or four letter string such as @"INDI" or @"FAM"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param xref An optional xref.
 @param subNodes An ordered collection of nodes. If `nil`, the node will create an empty collection.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref subNodes:(id)subNodes;

@end

extern NSString *GCLevelAttributeName;
extern NSString *GCXrefAttributeName;
extern NSString *GCTagAttributeName;
extern NSString *GCValueAttributeName;
extern NSString *GCLinkAttributeName;
