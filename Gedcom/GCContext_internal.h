//
//  GCContext_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

@interface GCContext ()

- (NSString *)xrefForEntity:(GCEntity *)entity;

- (GCEntity *)entityForXref:(NSString *)xref;

- (void)registerCallbackForXref:(NSString *)xref usingBlock:(void (^)(NSString *xref))block;

- (void)setXref:(NSString *)xref forEntity:(GCEntity *)entity;

- (void)activateXref:(NSString *)xref;

- (BOOL)shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object;

@end