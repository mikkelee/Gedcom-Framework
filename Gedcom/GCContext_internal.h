//
//  GCContext_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

#import "GedcomErrors.h"

@interface GCContext ()

- (NSString *)_xrefForEntity:(GCEntity *)entity;

- (GCEntity *)_entityForXref:(NSString *)xref;

- (void)_registerCallbackForXref:(NSString *)xref usingBlock:(void (^)(NSString *xref, GCEntity *entity))block;

- (void)_setXref:(NSString *)xref forEntity:(GCEntity *)entity;

- (void)_activateXref:(NSString *)xref;

- (BOOL)_shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object;

@end