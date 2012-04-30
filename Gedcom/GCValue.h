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
 
 GCValue objects are abstract and immutable. To change the value of an attribute, assign a new value object to it.
 
 Use one of the following subclasses:
 
 TODO
 
 */
@interface GCValue : NSObject <NSCoding, NSCopying>

/// @name Creating values

+ (id)valueWithGedcomString:(NSString *)gedcomString;

/// @name Comparing values

/** Compares the receiver to another GCValue.
 
 The exact comparison ... TODO
 
 @param other A GCValue object.
 @return `NSOrderedAscending` if the receiver is earlier than other, `NSOrderedDescending` if the receiver is later than other, and `NSOrderedSame` if they are equal.
 */
- (NSComparisonResult)compare:(id)other;

/// @name Gedcom access

/// The value as a Gedcom-compliant string
@property (readonly) NSString *gedcomString;

/// @name Displaying values

/// The value as a display-friendly string
@property (readonly) NSString *displayString;

@end