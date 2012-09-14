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

const char *formatString = "%e %b %Y %H:%M:%S";
const size_t MAXLEN = 80;
const NSUInteger lengthOfTimePart = 8;

static inline NSDate * dateFromNode(GCNode *node) {
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",
                            [[node valueForKey:@"DATE"] gedValue],
                            [[node valueForKeyPath:@"DATE.TIME"] gedValue]
                            ];
    
    struct tm  timeResult;
    strptime_l([dateString cStringUsingEncoding:NSASCIIStringEncoding], formatString, &timeResult, LC_GLOBAL_LOCALE);
    
    assert(mktime(&timeResult) > 0);
    
    return [NSDate dateWithTimeIntervalSince1970: mktime(&timeResult)];
}

static inline GCNode * nodeFromDate(NSDate *date) {
    char timeResult[80];
    
    time_t time = [date timeIntervalSince1970];
    struct tm timeStruct;
    localtime_r(&time, &timeStruct);
    
    strftime_l(timeResult, MAXLEN, formatString, &timeStruct, LC_GLOBAL_LOCALE);
    
    //NSLog(@"result: %@ => %@", date, [[NSString alloc] initWithBytes:timeResult length:strlen(timeResult) encoding:NSASCIIStringEncoding]);
    
    GCNode *timeNode = [GCNode nodeWithTag:@"TIME"
                                     value:[[NSString alloc] initWithBytes:timeResult + (strlen(timeResult)-lengthOfTimePart)
                                                                    length:lengthOfTimePart
                                                                  encoding:NSASCIIStringEncoding]];
	
    bool leadingSpace = strncmp(timeResult, " ", 1) == 0;
    
    GCNode *dateNode = [GCNode nodeWithTag:@"DATE"
                                     value:[[[NSString alloc] initWithBytes:leadingSpace ? timeResult+1 : timeResult
                                                                     length:strlen(timeResult)-(lengthOfTimePart + (leadingSpace ? 2 : 1))
                                                                   encoding:NSASCIIStringEncoding] uppercaseString]
                                  subNodes:@[timeNode]];
    
    //NSLog(@"dateNode: %@", dateNode);
    
    return [GCNode nodeWithTag:@"CHAN"
                         value:nil
                      subNodes:@[dateNode]];
}