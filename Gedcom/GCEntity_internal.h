//
//  GCEntity_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"

@interface GCEntity ()

- (id)_initWithType:(NSString *)type inContext:(GCContext *)context;

@property (nonatomic, readonly) NSString *xref;

@end