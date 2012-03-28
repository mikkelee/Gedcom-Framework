//
//  GCValue.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GCUndefinedValue = -1,
    GCStringValue,
    GCNumberValue,
    GCAgeValue,
    GCDateValue,
    GCBoolValue,
    GCGenderValue
} GCValueType;

typedef enum {
	GCUnknownGender = -1,
	GCMale,
	GCFemale
} GCGender;

@class GCAge;
@class GCDate;

@interface GCValue : NSObject

- (id)initWithType:(GCValueType)type value:(id)value;

- (NSComparisonResult)compare:(id)other;

+ (GCValueType)valueTypeNamed:(NSString *)name;

@property (readonly) NSString *stringValue;
@property (readonly) NSNumber *numberValue;
@property (readonly) GCAge *ageValue;
@property (readonly) GCDate *dateValue;
@property (readonly) BOOL boolValue;
@property (readonly) GCGender genderValue;

@end
