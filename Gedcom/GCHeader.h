//
//  GCHead.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

/**
 
 A header holds information that describes a GCFile such as its author, what software produced it, etc.
 
 */
@interface GCHeader : GCObject

#pragma mark Convenience constructor

/// @name Creating and initializing headers

/** Returns a header whose properties reflect the GCNode in the given GCContext.
 
 @param node A GCNode. Its tag code must be @"HEAD".
 @param context The context of the header.
 @return A new header.
 */
+ (id)headerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

@end
