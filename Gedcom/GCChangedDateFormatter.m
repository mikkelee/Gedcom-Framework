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

@implementation GCChangedDateFormatter

+ (id)sharedFormatter // fancy new ARC/GCD singleton!
{
    static dispatch_once_t predChangedDate = 0;
    __strong static id _sharedGCChangedDateFormatter = nil;
    dispatch_once(&predChangedDate, ^{
        _sharedGCChangedDateFormatter = [[self alloc] init];
    });
    return _sharedGCChangedDateFormatter;
}

- (GCChangedDateFormatter *)init
{
    self = [super init];
	
    if (self) {
        self.dateFormat = @"d MMM yyyy HH:mm:ss";
        self.shortMonthSymbols = @[@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC"];
    }
	
	return self;
}

- (NSDate *)dateWithNode:(GCNode *)node
{
    NSParameterAssert([node.gedTag isEqualToString:@"CHAN"]);
    
    NSString *dateString = [NSString stringWithFormat:@"%@ %@", 
                            [[node valueForKey:@"DATE"] gedValue], 
                            [[node valueForKeyPath:@"DATE.TIME"] gedValue]
                            ];
    
    NSParameterAssert(dateString);
    
    @synchronized(self) {
        NSDate *date = [self dateFromString:dateString];
        
        return date;
    }
}

- (GCNode *)nodeWithDate:(NSDate *)date
{
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
    
    return nil;
}

@end
