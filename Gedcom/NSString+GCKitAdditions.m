//
//  NSString+GCKitAdditions.m
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 03/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import "NSString+GCKitAdditions.h"

@implementation NSString (GCKitAdditions)

- (NSArray*)arrayOfLines
{
	NSUInteger length = [self length], 
	lineStart = 0, 
	lineEnd = 0,
	contentsEnd = 0;
    NSMutableArray *array = [NSMutableArray array];
    while (lineEnd < length) {
		//NSLog(@"lineStart: %d, lineEnd: %d, contentsEnd: %d", lineStart, lineEnd, contentsEnd);
        [self getLineStart:&lineStart end:&lineEnd
				 contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
        [array addObject:[self substringWithRange:NSMakeRange
						  (lineStart, contentsEnd - lineStart)]];
    }
	
	return array;
}

@end
