//
//  GCGedcomLoadingAdditions_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGedcomLoadingAdditions.h"

@interface GCObject (GCGedcomLoadingAdditions)

- (void)_addPropertyWithGedcomNode:(GCNode *)node;

- (void)_addPropertiesWithGedcomNodes:(NSArray *)nodes;

@end
