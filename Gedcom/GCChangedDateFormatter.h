//
//  GCChangedDateFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCNode;

/**
 
 NSFormatter subclass for translating between CHAN nodes and NSDates.
 
 */
@interface GCChangedDateFormatter : NSFormatter

/** Returns the shared instance of the formatter for the application, creating it if necessary.
 
 @return The shared formatter.
 */
+ (id)sharedFormatter;

/** Returns a GCNode constructed from a given NSDate.
 
 @param date An NSDate object.
 @return A node.
 */
- (GCNode *)nodeWithDate:(NSDate *)date;

/** Returns an NSDate interpreted from the values of a given CHAN node.
 
 @param node An NSDate object. Its gedTag must be `@"CHAN"`.
 @return An NSDate.
 */
- (NSDate *)dateWithNode:(GCNode *)node;

@end
