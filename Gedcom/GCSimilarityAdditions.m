//
//  GCSimilarityAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCSimilarityAdditions.h"

@implementation GCContext (GCSimilarityAdditions)

- (NSDictionary *)recordsSimilarTo:(GCRecord *)record
{
    return nil;
}

@end

@implementation GCRecord (GCSimilarityAdditions)

- (NSNumber *)similarityTo:(GCRecord *)record withWeights:(NSDictionary *)weights
{
    return nil;
}

- (NSNumber *)similarityTo:(GCRecord *)record
{
    return nil;
}

@end