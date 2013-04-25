//
//  GCSimilarityAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCContext.h"
#import "GCRecord.h"

@interface GCContext (GCSimilarityAdditions)

- (NSDictionary *)recordsSimilarTo:(GCRecord *)record;

@end

@interface GCRecord (GCSimilarityAdditions)

- (NSNumber *)similarityTo:(GCRecord *)record withWeights:(NSDictionary *)weights;

- (NSNumber *)similarityTo:(GCRecord *)record;

@end
