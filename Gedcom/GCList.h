//
//  GCList.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Gedcom/Gedcom.h>

/**
 
 GCValue subclass to handle lists of string values.
 
 */
@interface GCList : GCValue

/** Initializes and returns a list with the specified elements.
 
 @param elements A collection of elements.
 @return A new list.
 */
- (id)initWithElements:(NSArray *)elements;

/// Returns an array of the elements in the list.
@property (readonly) NSArray *elements;

@end
