//
//  GCContext_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

#import "GedcomErrors.h"

@class GCTag;
@class GCObject;

@interface GCContext () {
    GCHeaderEntity  *_header;
    GCSubmissionEntity *_submission;
    
    NSMutableArray *_families;
    NSMutableArray *_individuals;
    NSMutableArray *_multimedias;
    NSMutableArray *_notes;
    NSMutableArray *_repositories;
    NSMutableArray *_sources;
    NSMutableArray *_submitters;
    
    NSMutableArray *_customEntities;
    
    __weak id<NSObject, GCContextDelegate> _delegate;
}

- (NSString *)_xrefForEntity:(GCEntity *)entity;

- (GCEntity *)_entityForXref:(NSString *)xref create:(BOOL)create withClass:(Class)aClass;

- (void)_setXref:(NSString *)xref forEntity:(GCEntity *)entity;

- (void)_activateEntity:(GCEntity *)entity;

- (BOOL)_shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object;

- (void)_clearXrefs;
- (void)_renumberXrefs;

@property (strong, readonly) NSUndoManager *undoManager;

@end

@interface GCContext (GCMoreKeyValueAdditions)

- (void)_addEntity:(GCEntity *)entity;

@end