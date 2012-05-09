//
//  GCValue.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 26/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

@implementation GCValue 

- (id)init
{
    NSParameterAssert([self class] != [GCValue class]);
    
    return [super init];
}

+ (id)valueWithGedcomString:(NSString *)gedcomString
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [[self class] valueWithGedcomString:[aDecoder decodeObjectForKey:@"gedcomString"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self gedcomString] forKey:@"gedcomString"];
}

#pragma mark NSCopying conformance

- (id)copyWithZone:(NSZone *)zone
{
    return self; //values are immutable and thus safe to copy
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", [super description], [self gedcomString]];
}
//COV_NF_END

#pragma mark -

@dynamic gedcomString;
@dynamic displayString;

@end