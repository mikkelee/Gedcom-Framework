//
//  GCQualifiedAge.m
//  GCCoreData copy
//
//  Created by Mikkel Eide Eriksen on 13/06/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCQualifiedAge.h"


@implementation GCQualifiedAge

NSString * const GCAgeQualifier_toString[] = {
    @"<",
    @">"
};

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
        [self setAge:[coder decodeObjectForKey:@"age"]];
        [self setQualifier:[coder decodeIntegerForKey:@"qualifier"]];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self age] forKey:@"age"];
	[coder encodeInteger:[self qualifier] forKey:@"qualifier"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCQualifiedAge %@ %@]", GCAgeQualifier_toString[[self qualifier]], [self age]];
}

- (NSString *)gedcomString
{
	return [NSString stringWithFormat:@"%@ %@", GCAgeQualifier_toString[[self qualifier]], [self age]];
}

- (NSComparisonResult)compare:(id)other {
	if (other == nil) {
		return NSOrderedAscending;
	} else {
		return [self compare:[other refAge]];
	}
}

- (GCQualifiedAge *)copyWithZone:(NSZone *)zone
{
	GCQualifiedAge *copy = [[GCQualifiedAge alloc] init];
	
	[copy setAge:[self age]];
	[copy setQualifier:[self qualifier]];
	
	return copy;
}

- (GCSimpleAge *)refAge
{
	return [[self age] refAge];
}

@synthesize age;
@synthesize qualifier;

@end
