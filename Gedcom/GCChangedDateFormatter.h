//
//  GCChangedDateFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCNode;

@interface GCChangedDateFormatter : NSFormatter

+ (id)sharedFormatter;

- (GCNode *)nodeWithDate:(NSDate *)date;
- (NSDate *)dateWithNode:(GCNode *)node;

@end
