//
//  GCList.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

@interface GCList ()

@property NSMutableArray *elements;

@end

@implementation GCList

- (instancetype)initWithElements:(NSArray *)elements
{
    self = [super init];
    
    if (self) {
        _elements = elements;
    }
    
    return self;
}

+ (instancetype)valueWithGedcomString:(NSString *)gedcomString
{
    NSMutableArray *elements = [NSMutableArray array];
        
    for (NSString *element in [gedcomString componentsSeparatedByString:@","]) {
        [elements addObject:[element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    
    return [[self alloc] initWithElements:elements];
}

- (BOOL)_isContainedInArray:(NSArray *)array
{
    for (NSString *element in _elements) {
        if (![array containsObject:[element uppercaseString]]) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)gedcomString
{
    return [_elements componentsJoinedByString:@", "];
}

- (NSString *)displayString
{
    return self.gedcomString;
}

@end
