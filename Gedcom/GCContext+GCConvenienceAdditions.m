//
//  GCContext+GCConvenienceAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext+GCConvenienceAdditions.h"

#import "GCProperty.h"
#import "GCRecord.h"

@implementation GCContext (GCConvenienceAdditions)

- (void)addProperty:(GCProperty *)property toRecordsOfType:(NSString *)type
{
    for (GCRecord *record in [self valueForKey:type]) {
        [record.mutableProperties addObject:[property copy]];
    }
}

@end
