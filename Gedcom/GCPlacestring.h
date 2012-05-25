//
//  GCPlacestring.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCString.h"

/**
 
 A Gedcom place string value. Provides a hierarchy of places. Sorting ... TODO desc
 
 */
@interface GCPlacestring : GCString

+ (id)rootPlace;

/// The name of the place string.
@property (readonly) NSString *name;

/// The jurisdiction containing the place.
@property (readonly) GCPlacestring *superPlace;

/// 
@property (readonly) NSDictionary *subPlaces;

@end
