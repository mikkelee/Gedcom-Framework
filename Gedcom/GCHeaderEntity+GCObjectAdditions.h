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

+ (instancetype)defaultHeaderInContext:(GCContext *)context;

@end
