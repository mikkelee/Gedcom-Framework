//
//  GCAgeParser.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCAge.h"

#pragma mark GCAgeAssembler

@interface GCAgeAssembler : NSObject

- (void)initialize;

@property (copy) GCAge *age;

@end

#pragma mark GCAgeParser

@interface GCAgeParser : NSObject

+ (GCAgeParser *)sharedAgeParser;
- (GCAge *)parseGedcom:(NSString *)g;

@end
