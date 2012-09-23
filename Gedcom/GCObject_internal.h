//
//  GCObject_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

#import "ValidationHelpers.h"

@interface GCObject ()

#pragma mark Description helper

- (NSString *)propertyDescriptionWithIndent:(NSUInteger)level;

#pragma mark Keyed subscript accessors

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key;

@end

