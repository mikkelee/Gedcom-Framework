//
//  GCInvalidDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDate.h"

@interface GCInvalidDate : GCDate

@property (copy) NSString *string;
@property (retain, readonly) NSCalendar *calendar;

@end
