//
//  GCAgeFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 22/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCAgeFormatter : NSFormatter

- (NSString *)editingStringForObjectValue:(id)anObject;
- (NSString *)stringForObjectValue:(id)anObject;

- (BOOL)getObjectValue:(id *)outVal forString:(NSString *)string errorDescription:(NSString **)error;
- (BOOL)getObjectValue:(out id *)outVal forString:(NSString *)aString range:(inout NSRange *)rangep error:(out NSError **)error;


@end
