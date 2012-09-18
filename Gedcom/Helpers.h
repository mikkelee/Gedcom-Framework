//
//  Helpers.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <time.h>
#include <xlocale.h>

#import "GCNode.h"

const char *formatString = "%e %b %Y %H:%M:%S %z";

static inline NSDate * dateFromNode(GCNode *node) {
    NSString *dateString = [NSString stringWithFormat:@"%@ %@ %@",
                            [[node valueForKey:@"DATE"] gedValue],
                            [[node valueForKeyPath:@"DATE.TIME"] gedValue],
                            @"+0000"
                            ];
    
    struct tm  timeResult;
    
    strptime_l([dateString cStringUsingEncoding:NSASCIIStringEncoding], formatString, &timeResult, NULL);
    
    assert(mktime(&timeResult) > 0);
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: mktime(&timeResult)];
    
    //NSLog(@"strptime_l: %@ => %ld => %@", dateString, mktime(&timeResult), date);
    
    return date;
}

const size_t MAXLEN = 80;
const NSUInteger lengthOfTimePart = 8;
const NSUInteger lengthOfTimezone = 6;

static inline GCNode * nodeFromDate(NSDate *date) {
    char timeResult[MAXLEN];
    
    time_t time = [date timeIntervalSince1970];
    struct tm timeStruct;
    gmtime_r(&time, &timeStruct);
    
    strftime_l(timeResult, MAXLEN, formatString, &timeStruct, NULL);
    
    //NSLog(@"strftime_l: %@ => %ld => %@", date, time, [[NSString alloc] initWithBytes:timeResult length:strlen(timeResult) encoding:NSASCIIStringEncoding]);
    
    bool leadingSpace = strncmp(timeResult, " ", 1) == 0;
    
    NSString *timeString = [[NSString alloc] initWithBytes:timeResult + (strlen(timeResult)-(lengthOfTimePart + lengthOfTimezone))
                                                    length:lengthOfTimePart
                                                  encoding:NSASCIIStringEncoding];
    
    
    
    NSString *dateString = [[[NSString alloc] initWithBytes:leadingSpace ? timeResult+1 : timeResult
                                                     length:strlen(timeResult)-(lengthOfTimezone + lengthOfTimePart + (leadingSpace ? 2 : 1))
                                                   encoding:NSASCIIStringEncoding] uppercaseString];
    
    GCNode *timeNode = [GCNode nodeWithTag:@"TIME"
                                     value:timeString];
	
    GCNode *dateNode = [GCNode nodeWithTag:@"DATE"
                                     value:dateString
                                  subNodes:@[timeNode]];
    
    //NSLog(@"dateNode: %@", dateNode);
    
    return [GCNode nodeWithTag:@"CHAN"
                         value:nil
                      subNodes:@[dateNode]];
}