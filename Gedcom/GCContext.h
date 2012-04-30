//
//  GCXRefStore.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCEntity;

/**
 
 A context provides lookup functionality related to xrefs.
 
 */
@interface GCContext : NSObject <NSCoding>

/// @name Obtaining a context

/// Creates a new context.
+ (id)context;

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
- (void)registerBlock:(void (^)(NSString *xref))block forXref:(NSString *)xref;

/// @name Registering Xrefs

/** Stores an xref for an entity.
 
 If a callback has been registered for the xref, it is issued.
 
 Used during import from Gedcom data.
 
 @param xref A string containing an xref.
 @param entity An entity to be associated with the xref.
 */
- (void)setXref:(NSString *)xref forEntity:(GCEntity *)entity;

@end
