//
//  GCSanityCheckAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"
#import "GCRecord.h"

@interface GCContext (GCSanityCheckAdditions)

/** Runs various sanity checks on the receiver and its entities.
 
 @param error An NSError object describing the inconsistencies, if any.
 @return `YES` if the context is sane, `NO` if not.
 */
- (BOOL)sanityCheck:(NSError **)error;

@end

@interface GCEntity (GCSanityCheckAdditions)

/** Runs various sanity checks on the receiver.
 
 @param error An NSError object describing the inconsistencies, if any.
 @return `YES` if the entity is sane, `NO` if not.
 */
- (BOOL)sanityCheck:(NSError **)error;

@end
