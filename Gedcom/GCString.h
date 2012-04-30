//
//  GCString.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

@interface GCString : GCValue

+ (id)valueWithGedcomString:(NSString *)gedcomString;

@end
