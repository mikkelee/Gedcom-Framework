//
//  GCDateFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 14/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GCDateFormatter : NSFormatter {
}

- (NSString *)editingStringForObjectValue:(id)date;
- (NSString *)stringForObjectValue:(id)date;
//- (NSAttributedString *)attributedStringForObjectValue:(id)dateC withDefaultAttributes:(NSDictionary *)attributes;

- (BOOL)getObjectValue:(id *)dateC forString:(NSString *)string errorDescription:(NSString **)error;
- (BOOL)getObjectValue:(out id *)anObject forString:(NSString *)aString range:(inout NSRange *)rangep error:(out NSError **)error;

@end
