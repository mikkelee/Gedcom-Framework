//
//  GCGender.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

@interface GCGender : GCValue

+ (id)valueWithGedcomString:(NSString *)string;

+ (id)maleGender;

+ (id)femaleGender;

+ (id)unknownGender;

@end
