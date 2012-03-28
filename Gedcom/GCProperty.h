//
//  GCProperty.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

@interface GCProperty : GCObject

#pragma mark Convenience constructors

+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

@property GCObject *describedObject; //TODO better name?

@end
