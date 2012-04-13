//
//  GCDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 12/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDate : NSObject <NSCoding, NSCopying>

#pragma mark Initialization

- (id)initWithGedcom:(NSString *)gedcom;

#pragma mark Convenience constructor

+ (id)dateWithGedcom:(NSString *)gedcom;

#pragma mark Helpers

//TODO

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other;

#pragma mark Properties

@property (retain, readonly) NSString *gedcomString;
@property (retain, readonly) NSString *displayString;
@property (retain, readonly) NSString *description;

@property (readonly) NSUInteger year;
@property (readonly) NSUInteger month;
@property (readonly) NSUInteger day;

@end




