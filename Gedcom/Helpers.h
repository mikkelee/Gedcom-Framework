//
//  Helpers.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <time.h>

#import "GCNode.h"

static inline NSDate * dateFromNode(GCNode *node) {
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",
                            [[node valueForKey:@"DATE"] gedValue],
                            [[node valueForKeyPath:@"DATE.TIME"] gedValue]
                            ];
    
    struct tm  timeResult;
    const char *formatString = "%d %b %Y %H:%M:%S";
    strptime([dateString cStringUsingEncoding:NSASCIIStringEncoding], formatString, &timeResult);
    
    return [NSDate dateWithTimeIntervalSince1970: mktime(&timeResult)];
}

static inline GCNode * nodeFromDate(NSDate *date) {
    //TODO use strftime()?
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"d MMM yyyy";
    dateFormatter.shortMonthSymbols = @[@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC"];
    
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	timeFormatter.dateFormat = @"HH:mm:ss";
    
    GCNode *timeNode = [GCNode nodeWithTag:@"TIME"
                                     value:[timeFormatter stringFromDate:date]];
	
    GCNode *dateNode = [GCNode nodeWithTag:@"DATE"
                                     value:[dateFormatter stringFromDate:date]
                                  subNodes:@[timeNode]];
    
    return [GCNode nodeWithTag:@"CHAN"
                         value:nil
                      subNodes:@[dateNode]];
}