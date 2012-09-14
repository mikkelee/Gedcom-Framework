//
//  GCContext_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

@interface GCContext ()

/// @name Translating Xrefs

/** Returns an xref for the given entity.
 
 @param entity An entity.
 @return If an xref exists for the entity, it is returned. Otherwise one is created and returned.
 */
- (NSString *)xrefForEntity:(GCEntity *)entity;

/** Returns the entity for an xref.
 
 @param xref A string containing an xref.
 @return If an entity exists for the xref, it is returned. Otherwise `nil` is returned.
 */
- (GCEntity *)entityForXref:(NSString *)xref;

/// @name Registering callbacks

/** Register a callback for an xref.
 
 If an entity for the xref exists, the callback is issued immediately, otherwise it is saved until such a time as an entity exists.
 
 @param xref A string containing an xref.
 @param block A block that will be called as soon as an entity exists.
 */
- (void)registerCallbackForXref:(NSString *)xref usingBlock:(void (^)(NSString *xref))block;

/// @name Registering Xrefs

/** Stores an xref for an entity.
 
 If one or more callbacks has been registered for the xref, they are issued.
 
 Generally only used during import from Gedcom data.
 
 @param xref A string containing an xref.
 @param entity An entity to be associated with the xref.
 */
- (void)setXref:(NSString *)xref forEntity:(GCEntity *)entity;

#pragma mark Xref link methods

/** Used by GCXrefProtocol.
 
 Will cause the receiver to contact its delegate, if any.
 
 TODO: better name.
 
 @param xref A string containing an xref.
 */
- (void)activateXref:(NSString *)xref;

#pragma mark Unknown tag methods

- (void)encounteredUnknownTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object;

@end
