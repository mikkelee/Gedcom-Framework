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
#import "GCProperty.h"
#import "GCValue.h"

typedef double GCSimilarity;

@interface GCContext (GCSimilarityAdditions)

- (NSDictionary *)recordsSimilarTo:(GCRecord *)record;

@end

@interface GCRecord (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCRecord *)record;

@end

@interface GCProperty (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCProperty *)property;

@end

@interface GCValue (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCValue *)value;

@end