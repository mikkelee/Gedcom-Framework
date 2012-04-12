//
//  GCAgeFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 22/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GCAgeFormatter : NSFormatter

- (NSString *)editingStringForObjectValue:(id)anObject;
- (NSString *)stringForObjectValue:(id)anObject;
//- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes;

- (BOOL)getObjectValue:(id *)outVal forString:(NSString *)string errorDescription:(NSString **)error;
- (BOOL)getObjectValue:(out id *)outVal forString:(NSString *)aString range:(inout NSRange *)rangep error:(out NSError **)error;


@end
