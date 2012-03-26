//
//  GCChangedDateFormatter.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCChangedDateFormatter.h"

@implementation GCChangedDateFormatter

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
	if (![super init])
		return nil;
	
	[self setDateFormat:@"dd MMM yyyy HH:mm:ss"];
	
	return self;
}



@end
