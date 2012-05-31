//
//  GCPlacestring.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCString.h"

/**
 
 A Gedcom place string value. Provides a hierarchy of places; upon creation, places are split into jurisdictions on commas, in order of lowest to highest, as per the Gedcom spec. Thus, ordering by places will order by the highest juridiction first, then lower as necessary.
 
 */
@interface GCPlacestring : GCString

/// Returns the root-level place.
+ (id)rootPlace;

/// The name of the place string.
@property (readonly) NSString *name;

/// The jurisdiction containing the place.
@property (readonly) GCPlacestring *superPlace;

/// The sub-locations within the given place.
@property (readonly) NSDictionary *subPlaces;

@end
