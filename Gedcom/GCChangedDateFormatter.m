//
//  GCChangedDateFormatter.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCChangedDateFormatter.h"

#import "GCNode.h"
#import "GCTag.h"

@implementation GCChangedDateFormatter {
    NSDateFormatter *_dateFormatter;
}

+ (id)sharedFormatter // fancy new ARC/GCD singleton!
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedGCChangedDateFormatter = nil;
    dispatch_once(&pred, ^{
        _sharedGCChangedDateFormatter = [[self alloc] init];
    });
    return _sharedGCChangedDateFormatter;
}

- (GCChangedDateFormatter *)init
{
    self = [super init];
	
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
    }
	
	return self;
}

- (NSDate *)dateWithNode:(GCNode *)node
{
    NSParameterAssert([[node gedTag] isEqualToString:@"CHAN"]);
    
	return [_dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", 
                                          [[node valueForKey:@"DATE"] gedValue], 
                                          [[node valueForKeyPath:@"DATE.TIME"] gedValue]
                                          ]];
	
}

- (GCNode *)nodeWithDate:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"d MMM yyyy"];
	[dateFormatter setShortMonthSymbols:[NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil]];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat:@"HH:mm:ss"];
    
    GCNode *timeNode = [GCNode nodeWithTag:@"TIME" 
                                     value:[timeFormatter stringFromDate:date]];
	
    GCNode *dateNode = [GCNode nodeWithTag:@"DATE" 
                                     value:[dateFormatter stringFromDate:date]
                                  subNodes:[NSArray arrayWithObject:timeNode]];
    
    return [GCNode nodeWithTag:@"CHAN" 
                         value:nil 
                      subNodes:[NSArray arrayWithObject:dateNode]];
    
    return nil;
}

@end
