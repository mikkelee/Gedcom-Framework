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

@interface GCRelationship ()

@property (weak) GCRelationship *other;
@property (readonly) NSString *reverseRelationshipType;

@end

@implementation GCRelationship {
	GCEntity *_target;
}

#pragma mark NSKeyValueCoding overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    if (![key isEqualToString:@"target"]) {
        [keyPaths addObject:@"target"];
    }
    
    return keyPaths;
}

#pragma mark Gedcom access

- (GCNode *)gedcomNode
{
    GCParameterAssert(_target);
    
    return [[GCNode alloc] initWithTag:self.gedTag.code
								 value:self.target.xref
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    self.target = [self.context _entityForXref:gedcomNode.gedValue create:NO withClass:nil];
    
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
    
    return [NSString stringWithFormat:@"%@<%@: %p> (describing: %p target: %@) {\n%@%@};\n", indent, [self className], self, self.describedObject, _target.xref, [self _propertyDescriptionWithIndent:level+1], indent];
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
    NSAssert(self.context, @"You must add the root object to a context before setting the target!");
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
    return _target.xref;
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue 
                                           attributes:@{NSLinkAttributeName: _target.xref}];
}

@end

@implementation GCRelationship (GCGedcomLoadingAdditions)

- (id)initWithGedcomNode:(GCNode *)node onObject:(GCObject *)object
//TODO: cleanup
{
    GCTag *tag = [object.gedTag subTagWithCode:node.gedTag type:@"relationship"];
    
    id target = [object.context _entityForXref:node.gedValue create:YES withClass:tag.targetType];
    
    if ([object.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        if ([[object[tag.pluralName] valueForKey:@"target"] containsObject:target]) {
            return nil; // already exists
        }
    } else {
        if ([object[tag.name] valueForKey:@"target"] == target) {
            return nil; // already exists
        }
    }
    
    self = [super initWithGedcomNode:node onObject:object];
    
    if (self) {
        NSParameterAssert(self.describedObject == object);
        GCParameterAssert(object.context);
        
        self.target = target;
        
        NSParameterAssert(self.target);
    }
    
    return self;
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
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (_target == nil) {
        NSString *formatString = [frameworkBundle localizedStringForKey:@"Target is missing for key %@ (should be a %@)"
                                                                  value:@"Target is missing for key %@ (should be a %@)"
                                                                  table:@"Errors"];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.type, self.gedTag.targetType],
                                   NSAffectedObjectsErrorKey: self
                                   };
        
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                   code:GCTargetMissingError
                                                                 userInfo:userInfo]);
        isValid &= NO;
    } else if (![_target isKindOfClass:self.gedTag.targetType]) {
        NSString *formatString = [frameworkBundle localizedStringForKey:@"Target %@ is incorrect type for key %@ (should be %@)"
                                                                  value:@"Target %@ is incorrect type for key %@ (should be %@)"
                                                                  table:@"Errors"];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, _target, self.type, self.gedTag.targetType],
                                   NSAffectedObjectsErrorKey: self
                                   };
        
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                     code:GCIncorrectTargetTypeError
                                                                 userInfo:userInfo]);
        isValid &= NO;
    }
    
    if (!isValid) {
        *outError = returnError;
    }
    
    return isValid;
}

@end