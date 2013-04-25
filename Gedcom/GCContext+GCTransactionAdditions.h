//
//  GCContext+GCTransactionAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

@interface GCContext (GCTransactionAdditions)

/// @name Managing transactions

- (void)beginTransaction;

- (void)rollback;

- (void)commit;

@end