//
//  GCAttributedDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDate.h"

@class GCSimpleDate;

@interface GCAttributedDate : GCDate <NSCoding, NSCopying> {

}

@property (retain) GCSimpleDate *simpleDate;
@property (retain, readonly) NSCalendar *calendar;

@end
