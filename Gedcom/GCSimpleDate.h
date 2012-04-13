//
//  GCDateSimple.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDate.h"

@interface GCSimpleDate : GCDate

- (NSComparisonResult)compare:(id)other;

- (NSDate *)date;

@property (copy) NSDateComponents *dateComponents;
@property (retain) NSCalendar *calendar;

@end
