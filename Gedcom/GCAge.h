//
//  GCAge.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 18/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDate;

@interface GCAge : NSObject <NSCoding, NSCopying>

#pragma mark Initialization

- (id)initWithGedcom:(NSString *)gedcom;

#pragma mark Convenience constructor

+ (id)ageWithGedcom:(NSString *)gedcom;

#pragma mark Helpers

+ (id)ageFromDate:(GCDate *)fromDate toDate:(GCDate *)toDate;

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other;

#pragma mark Objective-C properties

@property (readonly) NSString *gedcomString;
@property (readonly) NSString *displayString;

@property (readonly) NSUInteger years;
@property (readonly) NSUInteger months;
@property (readonly) NSUInteger days;

@end
