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
 @param subNodes A collection of nodes. If `nil`, the node will create an empty collection.
 @return A new node.
 */
- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSOrderedSet *)subNodes;

#pragma mark Convenience constructors

/** Given a string of Gedcom data, will create an array of the nodes at level 0 of the data. Each node will further have subnodes as indicated by their level in the data.
 
 @param gedString A string of Gedcom data
 @return An array of nodes.
 */
+ (NSArray *)arrayOfNodesFromString:(NSString*) gedString;

#pragma mark Gedcom output

/// @name Gedcom output

/// The receiver including its subnodes as a string.
- (NSString *)gedcomString;

/// The receiver including its subnodes as an array of strings.
- (NSArray *)gedcomLines;

#pragma mark Objective-C properties

/// @name Accessing properties

/// The parent node of the receiver; will be `nil` for root nodes.
@property (weak, readonly) GCNode *parent;

/// The tag of the receiver; may not be `nil`.
@property (readonly) NSString *gedTag;

/// The value of the receiver; may be `nil`.
@property (readonly) NSString *gedValue;

/// The xref of the receiver; may be `nil`.
@property (readonly) NSString *xref;

/// The line separator of the receiver; usually `\n`.
@property (readonly) NSString *lineSeparator;

/// An ordered collection containing the subnodes of the receiver; may not be `nil`.
@property (readonly) NSOrderedSet *subNodes;

@end

@interface GCNode (GCConvenienceMethods)

/// @name Creating and initializing nodes

/** Returns a node with the specified properties.
 
 @param tag A four letter string such as @"INDI" or @"NOTE"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param value An optional value.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value;

/** Returns a node with the specified properties.
 
 @param tag A four letter string such as @"INDI" or @"NOTE"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param xref An optional xref.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref;

/** Returns a node with the specified properties.
 
 @param tag A four letter string such as @"INDI" or @"NOTE"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param value An optional value.
 @param subNodes An array of nodes. If `nil`, the node will create an empty collection.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value subNodes:(NSOrderedSet *)subNodes;

/** Returns a node with the specified properties.
 
 @param tag A four letter string such as @"INDI" or @"NOTE"; alternately an underscore-prefixed string such as @"_CUSTOMTAG".
 @param xref An optional xref.
 @param subNodes An array of nodes. If `nil`, the node will create an empty collection.
 @return A new node.
 */
+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref subNodes:(NSOrderedSet *)subNodes;

@end