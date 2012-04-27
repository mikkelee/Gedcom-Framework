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

#pragma mark Convenience constructor

+ (id)propertyForObject:(GCObject *)object withGedcomNode:(GCNode *)node;

#pragma mark Objective-C properties

@property GCObject *describedObject;

@end
