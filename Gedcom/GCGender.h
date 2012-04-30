//
//  GCGender.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

/**
 
 A Gedcom gender value.
 
 Note that Gedcom only has support for three types of gender.
 
 */
@interface GCGender : GCValue

/** Returns a singleton instance representing the male gender.
 
 @return A singleton instance representing the male gender.
 */
+ (id)maleGender;

/** Returns a singleton instance representing the female gender.
 
 @return A singleton instance representing the female gender.
 */
+ (id)femaleGender;

/** Returns a singleton instance representing an unknown gender.
 
 @return A singleton instance representing an unknown gender.
 */
+ (id)unknownGender;

@end
