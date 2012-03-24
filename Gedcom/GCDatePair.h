//
//  GCDatePair.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCSimpleDate.h"
#import "GCDate.h"

@interface GCDatePair : GCDate <NSCoding, NSCopying> {

}

@property (retain) GCSimpleDate *dateA;
@property (retain) GCSimpleDate *dateB;
@property (retain, readonly) NSCalendar *calendar;

@end
