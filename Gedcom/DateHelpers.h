//
//  DateHelpers.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCNode.h"

#include <time.h>
#include <xlocale.h>

const char *formatString = "%e %b %Y %H:%M:%S %z";

static inline NSDate * dateFromNode(GCNode *node) {
    NSArray *timeParts = [[[node valueForKeyPath:@"TIME"][0] gedValue] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    
    NSString *dateString = [NSString stringWithFormat:@"%@ %@ %@",
                            [node gedValue],
                            timeParts[0],
                            @"+0000"
                            ];
    
    struct tm  timeResult;
    
    strptime_l([dateString cStringUsingEncoding:NSASCIIStringEncoding], formatString, &timeResult, NULL);
    
    NSCAssert((&timeResult) > 0, @"Time broken!");
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: mktime(&timeResult)];
    
    if ([timeParts count] > 1) {
        NSTimeInterval milliseconds = [timeParts[1] intValue] * 0.001;
        
        date = [date dateByAddingTimeInterval:milliseconds];
    }
    
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
    
    double fraction = [date timeIntervalSince1970] - (long)[date timeIntervalSince1970];
    
    if (fraction) {
        timeString = [timeString stringByAppendingFormat:@".%03.0f", fraction * 1000];
    }
    
    
    NSString *dateString = [[[NSString alloc] initWithBytes:leadingSpace ? timeResult+1 : timeResult
                                                     length:strlen(timeResult)-(lengthOfTimezone + lengthOfTimePart + (leadingSpace ? 2 : 1))
                                                   encoding:NSASCIIStringEncoding] uppercaseString];
    
    GCNode *timeNode = [GCNode nodeWithTag:@"TIME"
                                     value:timeString];
	
    GCNode *dateNode = [GCNode nodeWithTag:@"DATE"
                                     value:dateString
                                  subNodes:@[timeNode]];
    
    //NSLog(@"date %@ => dateNode %@", date, dateNode);
    
    return dateNode;
}