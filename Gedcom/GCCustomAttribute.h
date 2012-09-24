//
//  GCCustomAttribute.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 18/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Gedcom/Gedcom.h>

/**
 
 Used to handle attributes for which no known tag exists. Should generally NOT be used in code, but exist to handle importing GEDCOM with unknown or custom tags.
 
 */
@interface GCCustomAttribute : GCAttribute

@end
