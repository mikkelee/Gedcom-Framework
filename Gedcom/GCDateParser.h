//
//  DateParser.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 16/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ParseKit/ParseKit.h>

@class GCDate;
@class GCDateAssembler;

@interface GCDateParser : NSObject {
	NSMutableDictionary *cache;
	
	PKParser *dateParser;
	GCDateAssembler *assembler;
	NSLock *lock;
}

+ (GCDateParser *)sharedDateParser;
- (GCDate *)parseGedcom:(NSString *)g;


@end
