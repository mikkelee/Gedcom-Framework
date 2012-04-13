//
//  GCChangedDateFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCNode;

@interface GCChangedDateFormatter : NSObject {

}

+ (id)sharedFormatter;

- (GCNode *)nodeWithDate:(NSDate *)date;
- (NSDate *)dateWithNode:(GCNode *)node;

@end
