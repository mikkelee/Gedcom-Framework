//
//  GedcomController.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCGedcomController : NSObject

+ (id)sharedController;

@property NSDictionary *tags;

@end
