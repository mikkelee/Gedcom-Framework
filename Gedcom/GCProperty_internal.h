//
//  GCProperty_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 29/03/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"
#import "GCRelationship.h"

@interface GCProperty ()

@property (weak, nonatomic) GCObject *describedObject;

@end

@interface GCRelationship ()

@property (weak) GCRelationship *other;
@property (readonly) NSString *reverseRelationshipType;

@end

