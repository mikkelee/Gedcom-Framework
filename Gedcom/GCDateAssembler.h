//
//  GCDateAssembler.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 20/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCDate;

@interface GCDateAssembler : NSObject {
	NSArray *monthNames;
	NSDateComponents *currentDateComponents;
}

- (void)initialize;

@property (copy) GCDate *date;

@end
