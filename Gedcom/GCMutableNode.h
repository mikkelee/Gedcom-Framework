//
//  GCMutableNode.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNode.h"

@interface GCMutableNode : GCNode

- (void)addSubNode: (GCMutableNode *) n;
- (void)addSubNodes: (NSArray *) a;

@property NSString *gedTag;
@property NSString *gedValue;
@property NSString *xref;
@property NSString *lineSeparator;
@property NSArray *subNodes;

@end
