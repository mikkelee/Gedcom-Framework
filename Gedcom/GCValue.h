//
//  GCValue.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GCStringValue,
    GCNumberValue,
    GCAgeValue,
    GCDateValue
} GCValueType;

@class GCAge;
@class GCDate;

@interface GCValue : NSObject

- (id)initWithType:(GCValueType)type value:(id)value;

- (NSComparisonResult)compare:(id)other;

@property (readonly) NSString *stringValue;
@property (readonly) NSNumber *numberValue;
@property (readonly) GCAge *ageValue;
@property (readonly) GCDate *dateValue;

@end
