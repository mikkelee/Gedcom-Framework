//
//  GCAttributedDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDate.h"

@class GCSimpleDate;

@interface GCAttributedDate : GCDate

@property (retain) GCSimpleDate *simpleDate;
@property (retain, readonly) NSCalendar *calendar;

@end
