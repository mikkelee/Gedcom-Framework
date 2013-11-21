//
//  NSString+JaroWinkler.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 21/11/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

@interface NSString (MEJaroWinklerAdditions)

- (double)jaroWinklerDistanceToString:(NSString *)string;

@end