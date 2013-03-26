//
//  GCCustomObjects.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 18/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

/**
 
 Used to handle entities for which no known tag exists. Should generally NOT be used in code, but exist to handle importing GEDCOM with unknown or custom tags.
 
 */
@interface GCCustomEntity : GCEntity

@end

/**
 
 Used to handle attributes for which no known tag exists. Should generally NOT be used in code, but exist to handle importing GEDCOM with unknown or custom tags.
 
 */
@interface GCCustomAttribute : GCAttribute

@end

/**
 
 Used to handle relationships for which no known tag exists. Should generally NOT be used in code, but exist to handle importing GEDCOM with unknown or custom tags.
 
 */
@interface GCCustomRelationship : GCRelationship

@end
