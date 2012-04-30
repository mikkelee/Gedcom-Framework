//
//  GCBool.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

/**
 
 A Gedcom boolean value.
 
 */
@interface GCBool : GCValue

/** Returns a singleton instance representing a true value.
 
 @return A singleton instance representing a true value.
 */
+ (id)yes;

/** Returns a singleton instance representing a false value.
 
 @return A singleton instance representing a false value.
 */
+ (id)no;

/// The receiver's value as a BOOL.
@property (readonly) BOOL boolValue;

@end
