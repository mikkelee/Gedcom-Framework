//
//  GCRelationnship.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCRelationship.h"

#import "GCRecord.h"
#import "GCTagAccessAdditions.h"

@interface GCRelationship ()

@property (weak) GCRelationship *other;
@property (readonly) NSString *reverseRelationshipType;

@end

@implementation GCRelationship

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    if (![key isEqualToString:@"target"]) {
        [keyPaths addObject:@"target"];
    }
    
    return keyPaths;
}

#pragma mark Comparison

- (NSComparisonResult)compare:(GCRelationship *)other
{
    NSComparisonResult result = [super compare:other];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    if (self.target != other.target) {
        return [self.target compare:other.target];
    }
    
    return NSOrderedSame;
}

#pragma mark Description

//COV_NF_START
- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSString *indent = @"";
    for (NSUInteger i = 0; i < level; i++) {
        indent = [NSString stringWithFormat:@"%@%@", indent, @"  "];
    }
    
    return [NSString stringWithFormat:@"%@<%@: %p> (describing: %p target: %@) {\n%@%@};\n", indent, [self className], self, self.describedObject, _target.xref, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark NSCoding conformance

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    
    if (self) {
        _target = [aDecoder decodeObjectForKey:@"target"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_target forKey:@"target"];
}

#pragma mark Objective-C properties

@synthesize target = _target;

- (void)setTarget:(GCRecord *)target
{
    //NSLog(@"%p :: %p :: %@ :: %@ = %p", self.rootObject, self, self.type, NSStringFromSelector(_cmd), target);
    
    @synchronized (self.context) {
        NSParameterAssert([target isKindOfClass:self.targetType]);
        
        GCRecord *oldTarget = _target;
        
        _target = target;
        
        if (self.reverseRelationshipType) {
            NSAssert(self.rootObject, @"You must add the relationship to an object before setting the target!");
            NSAssert(self.context, @"You must add the root object to a context before setting the target!");
            //NSLog(@"Got new target: %@ for self: %@", target, self);
            
            if (oldTarget) {
                // remove previous reverse relationship before changing target.
                //NSLog(@"Removing %@", oldTarget);
                
                [oldTarget.mutableProperties removeObject:self.other];
                self.other = nil;
            }
            
            if (target && self.other.rootObject != target) {
                //NSLog(@"test: %@", [target[self.reverseRelationshipType] valueForKey:@"target"]);
                
                id targetRels = [target valueForKey:self.reverseRelationshipType];
                
                NSArray *targets = nil;
                if ([target allowedOccurrencesOfPropertyType:self.reverseRelationshipType].max > 1) {
                    targets = [targetRels valueForKey:@"target"];
                } else {
                    targets = [targetRels valueForKey:@"target"] ? @[ [targetRels valueForKey:@"target"] ] : @[];
                }
                
                if (![targets containsObject:self.rootObject]) {
                    // set up new reverse relationship
                    //NSLog(@"Adding reverse relationship %@ with target: %@", self.reverseRelationshipType, self.rootObject);
                    
                    GCRelationship *other = [[[GCObject objectClassWithType:self.reverseRelationshipType] alloc] init];
                    
                    other.other = self;
                    self.other = other;
                    
                    if ([target allowedOccurrencesOfPropertyType:self.reverseRelationshipType].max > 1) {
                        [[target mutableArrayValueForKey:self.reverseRelationshipType] addObject:other];
                    } else {
                        [target setValue:other forKey:self.reverseRelationshipType];
                    }
                    
                    other.target = (GCRecord *)self.rootObject;
                }
            }
        }
    }
}

- (NSString *)reverseRelationshipType
{
    return nil; // override this to set up a reverse relationship
}

@end