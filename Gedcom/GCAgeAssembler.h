//
//  GCAgeAssembler.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 21/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCAge;

@interface GCAgeAssembler : NSObject {
	NSDateComponents *currentAgeComponents;
}

- (void)initialize;

@property (copy) GCAge *age;

@end
