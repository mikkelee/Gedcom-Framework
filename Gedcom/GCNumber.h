//
//  GCNumber.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

/**
 
 A Gedcom numeric value.
 
 */
@interface GCNumber : GCValue

/// The receiver's value as an NSNumber.
@property (readonly) NSNumber *numberValue;

@end
