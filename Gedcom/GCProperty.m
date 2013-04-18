//
//  GCProperty.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCProperty.h"

@interface GCProperty ()

@property (weak, nonatomic) GCObject *describedObject;

@end

@implementation GCProperty

#pragma mark Comparison

- (NSComparisonResult)compare:(GCProperty *)other
{
    if (![other isKindOfClass:[self class]]) {
        return NSOrderedAscending;
    }
    
    if (self.describedObject != other.describedObject) {
        return [self.describedObject compare:other.describedObject];
    }
    
    if (self.type != other.type) {
        return [self.type compare:other.type];
    }
    
    return NSOrderedSame;
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _describedObject = [aDecoder decodeObjectForKey:@"describedObject"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.describedObject forKey:@"describedObject"];
}

#pragma mark Objective-C properties

- (void)setDescribedObject:(GCObject *)describedObject
{
    //NSLog(@"%p :: %p :: %@ :: %@ = %p", self.rootObject, self, self.type, NSStringFromSelector(_cmd), describedObject);
    //TODO remove here?
    _describedObject = describedObject;
}

- (GCObject *)rootObject
{
    return self.describedObject.rootObject;
}

- (GCContext *)context
{
    return self.describedObject.context;
}

@end
