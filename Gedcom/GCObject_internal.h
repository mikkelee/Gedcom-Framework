//
//  GCObject_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

@interface GCObject ()

#pragma mark Description helpers

- (NSString *)descriptionWithIndent:(NSUInteger)level;
- (NSString *)propertyDescriptionWithIndent:(NSUInteger)level;

@end

