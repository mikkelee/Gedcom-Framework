//
//  GCRelationnship.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCRelationship.h"

#import "GCEntity.h"
#import "GCNode.h"
#import "GCContext_internal.h"

#import "GCObject_internal.h"
#import "GCProperty_internal.h"

@implementation GCRelationship {
	GCEntity *_target;
}

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    [keyPaths addObject:@"target"];
    [keyPaths removeObject:key];
    
    return keyPaths;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    GCParameterAssert(_target);
    
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:[self.context _xrefForEntity:_target]
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    self.target = [self.context _entityForXref:gedcomNode.gedValue];
    
    [super setSubNodes:gedcomNode.subNodes];
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
    
    return [NSString stringWithFormat:@"%@<%@: %p> (describing: %p target: %@) {\n%@%@};\n", indent, [self className], self, self.describedObject, _target ? [self.context _xrefForEntity:_target] : nil, [self _propertyDescriptionWithIndent:level+1], indent];
}
//COV_NF_END

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
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

- (GCEntity *)target
{
    return _target;
}

- (void)setTarget:(GCEntity *)target
{
    NSAssert(self.describedObject, @"You must add the relationship to an object before setting the target!");
    NSParameterAssert([target isKindOfClass:self.gedTag.targetType]);
    
    //NSLog(@"%p target: %p => %p", self, _target, target);
    
    GCEntity *oldTarget = _target;
    
    _target = target;
    
    if (self.reverseRelationshipType) {
        //NSLog(@"Got new target: %@ for self: %@", target, self);
        
        if (oldTarget) {
            // remove previous reverse relationship before changing target.
            //NSLog(@"Removing %@", oldTarget);
            
            [oldTarget.mutableProperties removeObject:self.other];
            self.other = nil;
        }
        
        if (target && self.other.rootObject != target) {
            //NSLog(@"test: %@", [target[self.reverseRelationshipType] valueForKey:@"target"]);
            
            if (![[target[self.reverseRelationshipType] valueForKey:@"target"] containsObject:self.rootObject]) {
                // set up new reverse relationship
                //NSLog(@"Adding reverse relationship %@ with target: %@", self.reverseRelationshipType, self.rootObject);
                
                GCTag *tag = [GCTag tagNamed:self.reverseRelationshipType];
                
                GCRelationship *other = [[tag.objectClass alloc] init];
                
                other.other = self;
                self.other = other;
                
                [target.mutableProperties addObject:other];
                
                other.target = (GCEntity *)self.rootObject;
            }
        }
    }
}

- (NSString *)reverseRelationshipType
{
    return nil; // override this to set up a reverse relationship
}

- (NSString *)displayValue
{
    return [self.context _xrefForEntity:_target];
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue 
                                           attributes:@{NSLinkAttributeName: [self.context _xrefForEntity:_target]}];
}

@end

@implementation GCRelationship (GCValidationMethods)

- (BOOL)validateObject:(NSError **)outError
{
    BOOL isValid = YES;
    
    NSError *returnError = nil;
    
    NSError *err = nil;
    
    BOOL superValid = [super validateObject:&err];
    
    if (!superValid) {
        isValid &= NO;
        returnError = combineErrors(returnError, err);
    }
    
    if (_target == nil) {
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                   code:GCTargetMissingError
                                                               userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Target is missing for key %@ (should be a %@)",  self.type, self.gedTag.targetType], NSAffectedObjectsErrorKey: self}]);
        isValid &= NO;
    } else if (![_target isKindOfClass:self.gedTag.targetType]) {
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                     code:GCIncorrectTargetTypeError
                                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Target %@ is incorrect type for key %@ (should be %@)", _target, self.type, self.gedTag.targetType], NSAffectedObjectsErrorKey: self}]);
        isValid &= NO;
    }
    
    if (!isValid) {
        *outError = returnError;
    }
    
    return isValid;
}

@end