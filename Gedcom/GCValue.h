//
//  GCValue.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 The value of an attribute.
 
 GCValue objects are abstract and immutable. To change the value of a GCAttribute, assign a new value object to it.
 
 Use one of the following subclasses:
 
 GCString,
 GCNamestring,
 GCPlacestring,
 GCNumber,
 GCDate,
 GCAge,
 GCGender, or
 GCBool.
 
 */
@interface GCValue : NSObject <NSCoding, NSCopying>

/// @name Creating values

/** Returns a new Gedcom value interpreted from the given string.
 
 `GCValue`s cannot be created directly, but must be done via a subclass.
 
 @param gedcomString a Gedcom string.
 @return A new value.
 
 */
+ (id)valueWithGedcomString:(NSString *)gedcomString;

/// @name Comparing values

/** Compares the receiver to another GCValue.
 
 The exact comparison method chosen depends on the subclass.
 
 @param other A GCValue object.
 @return `NSOrderedAscending` if the receiver is earlier than other, `NSOrderedDescending` if the receiver is later than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

/// @name Gedcom access

/// The value as a Gedcom-compliant string. Consider using the appropiate GCalueFormatter subclass.
@property (readonly) NSString *gedcomString;

/// @name Displaying values

/// The value as a display-friendly string. Consider using the appropiate GCalueFormatter subclass.
@property (readonly) NSString *displayString;

@end