//
//  GCObject+GCSanityCheckAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Gedcom/Gedcom.h>

@interface GCEntity (GCSanityCheckAdditions)

- (BOOL)sanityCheck:(NSError **)error;

@end
