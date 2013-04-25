//
//  GCContext+GCTransactionAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext+GCTransactionAdditions.h"
#import "GCContext_internal.h"

@implementation GCContext (GCTransactionAdditions)

- (void)beginTransaction
{
    [self.undoManager beginUndoGrouping];
}

- (void)rollback
{
    [self.undoManager endUndoGrouping];
    [self.undoManager undoNestedGroup];
}

- (void)commit
{
    [self.undoManager endUndoGrouping];
}

@end
