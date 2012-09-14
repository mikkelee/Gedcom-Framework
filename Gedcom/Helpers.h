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

const char *formatString = "%e %b %Y %H:%M:%S";
const size_t MAXLEN = 80;
const NSUInteger lengthOfTimePart = 8;

static inline NSDate * dateFromNode(GCNode *node) {
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",
                            [[node valueForKey:@"DATE"] gedValue],
                            [[node valueForKeyPath:@"DATE.TIME"] gedValue]
                            ];
    
    struct tm  timeResult;
    strptime([dateString cStringUsingEncoding:NSASCIIStringEncoding], formatString, &timeResult);
    
    return [NSDate dateWithTimeIntervalSince1970: mktime(&timeResult)];
}

static inline GCNode * nodeFromDate(NSDate *date) {
    char timeResult[80];
    
    time_t time = [date timeIntervalSince1970];
    struct tm timeStruct;
    localtime_r(&time, &timeStruct);
    
    strftime(timeResult, MAXLEN, formatString, &timeStruct);
    
    //NSLog(@"result: %@ => %@", date, [[NSString alloc] initWithBytes:timeResult length:strlen(timeResult) encoding:NSASCIIStringEncoding]);
    
    GCNode *timeNode = [GCNode nodeWithTag:@"TIME"
                                     value:[[NSString alloc] initWithBytes:timeResult + (strlen(timeResult)-lengthOfTimePart)
                                                                    length:lengthOfTimePart
                                                                  encoding:NSASCIIStringEncoding]];
	
    GCNode *dateNode = [GCNode nodeWithTag:@"DATE"
                                     value:[[[NSString alloc] initWithBytes:(strncmp(timeResult, " ", 1) == 0) ? timeResult+1 : timeResult
                                                                    length:strlen(timeResult)-(lengthOfTimePart+2)
                                                                  encoding:NSASCIIStringEncoding] uppercaseString]
                                  subNodes:@[timeNode]];
    
    //NSLog(@"dateNode: %@", dateNode);
    
    return [GCNode nodeWithTag:@"CHAN"
                         value:nil
                      subNodes:@[dateNode]];
}