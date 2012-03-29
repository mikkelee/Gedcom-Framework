//
//  GCAgeParser.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 20/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ParseKit/ParseKit.h>

@class GCAge;
@class GCAgeAssembler;

@interface GCAgeParser : NSObject

+ (GCAgeParser *)sharedAgeParser;
- (GCAge *)parseGedcom:(NSString *)g;

@end
