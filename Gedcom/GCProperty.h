//
//  GCProperty.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

/**
 
 Abstract property. Subclasses are GCAttribute and GCRelationship.
 
 */
@interface GCProperty : GCObject

#pragma mark Objective-C properties

/// @name Accessing properties

/// The object being described by the receiver.
@property (weak, nonatomic, readonly) GCObject *describedObject;

@end
