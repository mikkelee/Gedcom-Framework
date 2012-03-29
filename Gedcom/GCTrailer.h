//
//  GCTrailer.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

@interface GCTrailer : GCObject

+ (id)trailerWithGedcomNode:(GCNode *)node inContext:(GCContext *)context;

@end
