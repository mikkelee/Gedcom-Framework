//
//  GCDateParser.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCDate.h"

@interface GCDateParser : NSObject

+ (GCDateParser *)sharedDateParser;
- (GCDate *)parseGedcom:(NSString *)g;


@end

