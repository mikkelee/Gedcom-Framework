//
//  GCBool.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

/**
 
 A Gedcom boolean value. Note that there is no explicit "false" in the Gedcom specification, only yes(true) and undecided.
 
 */
@interface GCBool : GCValue

/** Returns a singleton instance representing a true value.
 
 @return A singleton instance representing a true value.
 */
+ (id)yes;

/** Returns a singleton instance representing an undecided value.
 
 @return A singleton instance representing an undecided value.
 */
+ (id)undecided;

/// The receiver's value as a BOOL.
@property (readonly) BOOL boolValue;

@end
