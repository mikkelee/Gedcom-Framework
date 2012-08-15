//
//  GCNumber.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNumber.h"

@implementation GCNumber {
    NSNumber *_contents;
}

- (id)initWithGedcomString:(NSString *)gedcomString
{
    self = [super init];
    
    if (self) {
        _contents = @([gedcomString integerValue]);
    }
    
    return self;
}

+ (id)valueWithGedcomString:(NSString *)gedcomString
{
    return [[self alloc] initWithGedcomString:gedcomString];
}

- (NSComparisonResult)compare:(id)other
{
    return [[self numberValue] compare:[other numberValue]];
}

- (NSString *)gedcomString
{
    return [_contents stringValue];
}

- (NSString *)displayString
{
    return [_contents stringValue];
}

- (NSNumber *)numberValue
{
    return _contents;
}

@end
