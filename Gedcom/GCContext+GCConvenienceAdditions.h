//
//  GCContext+GCConvenienceAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

@class GCProperty;

@interface GCContext (GCConvenienceAdditions)

- (void)addProperty:(GCProperty *)property toRecordsOfType:(NSString *)type;

@end
