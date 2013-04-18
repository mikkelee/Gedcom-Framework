//
//  GCObject+GCConvenienceAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject+GCConvenienceAdditions.h"

#import "GCRelationship.h"

@implementation GCObject (GCConvenienceAdditions)

- (NSArray *)relatedEntities
{
    NSMutableArray *targets = [NSMutableArray array];
    
    for (GCObject *object in self.properties) {
        if ([object isKindOfClass:[GCRelationship class]]) {
            [targets addObject:((GCRelationship *)object).target];
        }
        [targets addObjectsFromArray:object.relatedEntities];
    }
    
    return [targets copy];
}

@end