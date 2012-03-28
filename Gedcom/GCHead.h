//
//  GCHead.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

@interface GCHead : GCObject

#pragma mark Convenience constructors

+ (id)headWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

@end
