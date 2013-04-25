//
//  GCHeaderEntity+GCObjectAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeaderEntity.h"

@class GCContext;

@interface GCHeaderEntity (GCObjectAdditions)

/** Creates and returns a minimal GCHeaderEntity with default values. Note this also means a GCSubmitterEntity will be created.
 
 @param context The context in which the header will reside.
 @return A new header.
 */
+ (instancetype)defaultHeaderInContext:(GCContext *)context;

@end
