//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCContext.h"

#import "GCEntity.h"
#import "GCHeader.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

@interface GCObject () 

@end

@implementation GCObject {
    NSMutableOrderedSet *_propertyStore;
}

#pragma mark Initialization

- (id)init
{
    NSLog(@"You must use -initWithType: to initialize!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithType:(NSString *)type
{
    self = [super init];
    
    NSParameterAssert([self class] != [GCObject class]);
    NSParameterAssert([self class] != [GCProperty class]);
    
    if (self) {
        _tag = [GCTag tagNamed:type];
        _propertyStore = [NSMutableOrderedSet orderedSet];
    }
    
    return self;    
}

#pragma mark GCProperty access

static __strong NSMutableDictionary *_validPropertiesByType;

- (NSOrderedSet *)validProperties
{
    @synchronized(_validPropertiesByType) {
        if (!_validPropertiesByType) {
            _validPropertiesByType = [NSMutableDictionary dictionary];
        }
        
        NSOrderedSet *_validProperties = [_validPropertiesByType objectForKey:[self type]];
        
        if (!_validProperties) {
            NSMutableOrderedSet *valid = [NSMutableOrderedSet orderedSetWithCapacity:[[_tag validSubTags] count]];
            
            for (id subTag in [_tag validSubTags]) {
                [valid addObject:[subTag name]];
            }
            
            _validProperties = [valid copy];
            
            [_validPropertiesByType setObject:_validProperties forKey:[self type]];
        }
        
        return _validProperties;
    }
}

- (BOOL)allowsMultiplePropertiesOfType:(NSString *)type
{
    GCAllowedOccurrences occurrences = [_tag allowedOccurrencesOfSubTag:[GCTag tagNamed:type]];
    
    return occurrences.max > 1;
}

#pragma mark NSKeyValueCoding overrides

- (void)_internalSetValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[GCProperty class]]) {
        [[self mutableArrayValueForKey:@"properties"] addObject:value];
    } else if ([value isKindOfClass:[GCValue class]]) {
        [self addAttributeWithType:key value:value];
    } else if ([value isKindOfClass:[GCEntity class]]) {
        [self addRelationshipWithType:key target:value];
    } else {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidKVCValueTypeException"
														 reason:[NSString stringWithFormat:@"Invalid value %@ for setValue:forKey:", value]
													   userInfo:nil];
		@throw exception;
    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([[self validProperties] containsObject:key]) {
        if ([self allowsMultiplePropertiesOfType:key]) {
            NSParameterAssert([value respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]);
            [self setNilValueForKey:key]; //clean first
            for (id item in value) {
                [self _internalSetValue:item forKey:key];
            }
        } else {
            [self _internalSetValue:value forKey:key];
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setNilValueForKey:(NSString *)key
{
    if ([[self validProperties] containsObject:key]) {
        NSIndexSet *indexesForRemoval = [_propertyStore indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[(GCProperty *)obj type] isEqualToString:key];
        }];
        [_propertyStore removeObjectsAtIndexes:indexesForRemoval];
    } else {
        [super setNilValueForKey:key];
    }
}

- (id)valueForKey:(NSString *)key
{
    if ([key hasSuffix:@"@primary"]) {
        NSString *cleanKey = [[key componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        if ([[self valueForKey:cleanKey] count] > 0) {
            return [[self valueForKey:cleanKey] objectAtIndex:0];
        } else {
            return nil;
        }
    } else if ([[self validProperties] containsObject:key]) {
        @synchronized(_propertyStore) {
            NSIndexSet *indexes = [_propertyStore indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [[(GCProperty *)obj type] isEqualToString:key];
            }];
            
            if ([self allowsMultiplePropertiesOfType:key]) {
                return [_propertyStore objectsAtIndexes:indexes];
            } else {
                return [[_propertyStore objectsAtIndexes:indexes] lastObject];
            }
        }
    } else {
        return [super valueForKey:key];
    }
}

#pragma mark NSKeyValueObserving overrides

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    
    [keyPaths addObject:@"gedcomString"];
    [keyPaths addObject:@"gedcomNode"];
    [keyPaths addObject:@"properties"];
    
    GCTag *tag = [[GCTag tagsByName] objectForKey:key];
    
    if (tag != nil) {
        for (GCTag *subTag in [tag validSubTags]) {
            NSString *keyPath = [subTag name];
            [keyPaths addObject:keyPath];
            /*
            GCTag *subSubTag = subTag;
            while ([[subSubTag validSubTags] count] > 0) {
                for (GCTag *subSubSubTag in [subSubTag validSubTags]) {
                    
                }
            }*/
        }
    } else if ([key isEqualToString:@"properties"]) {
        [keyPaths addObjectsFromArray:[[GCTag tagsByName] allKeys]];
    }
    
    [keyPaths removeObject:key];
    
    return keyPaths;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"gedcomNode"] || [key isEqualToString:@"gedcomString"]) {
        return NO;
    } else {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

#pragma mark GCProperty collection accessors

- (void)setDescribedObjectForProperty:(GCProperty *)property
{
    if ([property describedObject]) {
        [[[property describedObject] mutableArrayValueForKey:@"properties"] removeObject:property];
    }
    
    [property setValue:self forKey:@"primitiveDescribedObject"];
}

- (NSUInteger)countOfProperties
{
    return [_propertyStore count];
}

- (id)objectInPropertiesAtIndex:(NSUInteger)index
{
    return [_propertyStore objectAtIndex:index];
}

/*
 - (void)getProperties:(GCProperty **)buffer range:(NSRange)inRange
 {
 [_propertyStore getObjects:buffer range:inRange];
 }
 */
/*
- (void)insertObject:(GCProperty *)object inPropertiesAtIndex:(NSUInteger)index
{
    [self setDescribedObjectForProperty:object];
    [_propertyStore insertObject:object atIndex:index];
}

- (void)removeObjectFromPropertiesAtIndex:(NSUInteger)index
{
    [[_propertyStore objectAtIndex:index] setValue:nil forKey:@"primitiveDescribedObject"];
    [_propertyStore removeObjectAtIndex:index];
}
*/
/* //Optional. Implement if benchmarking indicates that performance is an issue.
 - (void)replaceObjectInPropertiesAtIndex:(NSUInteger)index withObject:(id)object
 {
 
 }
 */
/*
- (NSEnumerator *)enumeratorOfProperties
{
    return [_propertyStore objectEnumerator];
}*/
/*
- (GCProperty *)memberOfProperties:(GCProperty *)object
{
    return [_propertyStore containsObject:object] ? object : nil;
}
*/
- (void)insertObject:(GCProperty *)property inPropertiesAtIndex:(NSUInteger)index
{
    NSParameterAssert(property);
    NSParameterAssert([property isKindOfClass:[GCProperty class]]);
    //NSParameterAssert([[property gedTag] isCustom] || [[self validProperties] containsObject:[property type]]);
    
    [self setDescribedObjectForProperty:property];
    
    //[self willChangeValueForKey:@"gedcomString"];
    
    @synchronized(_propertyStore) {
        __block GCObject *existingPropertyOfType = nil;
        
        [_propertyStore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(GCObject *)obj type] isEqualToString:[property type]]) {
                existingPropertyOfType = obj;
                *stop = YES;
            }
        }];
        
        if (existingPropertyOfType && ![self allowsMultiplePropertiesOfType:[property type]]) {
            [_propertyStore removeObject:property];
        }
        
        [_propertyStore addObject:property];
    }
    
    //[self didChangeValueForKey:@"gedcomString"];
}

- (void)removeObjectFromPropertiesAtIndex:(NSUInteger)index
{
    GCProperty *property = [_propertyStore objectAtIndex:index];
    
    if (property == nil) {
        return;
    }
    
    NSParameterAssert([property isKindOfClass:[GCProperty class]]);
    NSParameterAssert([property describedObject] == self);
    
    //[self willChangeValueForKey:@"gedcomString"];
    
    @synchronized(_propertyStore) {
        [_propertyStore removeObject:property];
    }
    
    [property setValue:nil forKey:@"primitiveDescribedObject"];
    
    //[self didChangeValueForKey:@"gedcomString"];
}

/* //Optional. Implement if benchmarking indicates that performance is an issue.
 - (void)intersectProperties:(NSSet *)objects
 {
 
 }
 */

#pragma mark Gedcom access

- (NSArray *)subNodes
{
    NSMutableArray *subNodes = [NSMutableArray array];
    
    @synchronized(_propertyStore) {
        NSArray *sortedProperties = [_propertyStore sortedArrayUsingComparator:^NSComparisonResult(GCProperty *obj1, GCProperty *obj2) {
            NSNumber *obj1index = [NSNumber numberWithInt:[[self validProperties] indexOfObject:[obj1 type]]];
            NSNumber *obj2index = [NSNumber numberWithInt:[[self validProperties] indexOfObject:[obj2 type]]];
            
            NSComparisonResult result = [obj1index compare:obj2index];
            
            if (result == NSOrderedSame) {
                result = [obj1 compare:obj2];
            }
            
            return result;
        }];
        
        for (GCProperty *property in sortedProperties) {
            [subNodes addObject:[property gedcomNode]];
        }
    }
    
	return subNodes;
}

#pragma mark Comparison

- (NSComparisonResult)compare:(id)other
{
    //subclasses override to get actual result.
    return NSOrderedSame;
}

#pragma mark Equality

- (BOOL)isEqualTo:(id)other
{
    return [[self gedcomString] isEqualToString:[other gedcomString]];
}
/*
 - (BOOL)isEqual:(id)other
 {
 if (other == self) {
 return YES;
 }
 
 return [[self gedcomString] isEqualToString:[other gedcomString]];
 }
 
 - (NSUInteger)hash
 {
 return [[self gedcomString] hash];
 }*/

#pragma mark NSCoding conformance

//COV_NF_START
- (id)initWithCoder:(NSCoder *)aDecoder
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self doesNotRecognizeSelector:_cmd];    
}
//COV_NF_END

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (type: %@)", [super description], [self type]];
}
//COV_NF_END

#pragma mark Objective-C properties

- (NSString *)type
{
    return [_tag name];
}

- (BOOL)allowsProperties
{
    return ([[self validProperties] count] > 0); //TODO (see cocoa-dev reply)
}

@synthesize gedTag = _tag;

@dynamic context;
@dynamic gedcomNode;
@dynamic displayValue;
@dynamic attributedDisplayValue;

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    //TODO willChangeValue for gedcomString?
    
    NSMutableArray *originalProperties = [[self propertiesArray] mutableCopy];
    
    //NSLog(@"originalProperties: %@", originalProperties);
    
    for (GCNode *subNode in [gedcomNode subNodes]) {
        if ([[subNode gedTag] isEqualToString:@"CHAN"]) {
            continue; //TODO ?
        }
        
        NSIndexSet *matches = [originalProperties indexesOfObjectsWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[[(GCProperty *)obj gedTag] code] isEqualToString:[subNode gedTag]];
        }];
        
        if ([matches count] < 1) {
            //NSLog(@"adding new property for %@", subNode);
            [GCProperty propertyForObject:self withGedcomNode:subNode];
        } else {
            GCProperty *property = [originalProperties objectAtIndex:[matches firstIndex]];
            [originalProperties removeObject:property];
            //NSLog(@"modifying property %@ with %@", property, subNode);
            [property setGedcomNode:subNode];
        }
    }
    
    //NSLog(@"after adding to propertiesArray: %@", [self propertiesArray]);
    
    //NSLog(@"removing originalProperties: %@", originalProperties);
    
    //remove the left over objects:
    for (GCProperty *property in originalProperties) {
        [[self propertiesArray] removeObject:property];
    }
    
    //NSLog(@"propertiesArray: %@", [self propertiesArray]);
}

- (NSString *)gedcomString
{
    return [[self gedcomNode] gedcomString];
}

- (void)setGedcomString:(NSString *)gedcomString
{
    NSArray *nodes = [GCNode arrayOfNodesFromString:gedcomString];
    
    NSParameterAssert([nodes count] == 1);
    
    GCNode *node = [nodes lastObject];
    
    NSParameterAssert([[[self gedTag] code] isEqualToString:[node gedTag]]);
    
    [self setGedcomNode:node];
}

- (NSAttributedString *)attributedGedcomString
{
    NSMutableAttributedString *gedcomString = [[[self gedcomNode] attributedGedcomString] mutableCopy];
    
    [gedcomString enumerateAttributesInRange:NSMakeRange(0, [gedcomString length])
                                     options:(kNilOptions) 
                                  usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                      if ([attrs objectForKey:GCLevelAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:range];
                                      } else if ([attrs objectForKey:GCXrefAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
                                      } else if ([attrs objectForKey:GCTagAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:range];
                                      } else if ([attrs objectForKey:GCLinkAttributeName]) {
                                          NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@/%@",
                                                                                      @"xref",
                                                                                      [[self context] name],
                                                                                      [attrs objectForKey:GCLinkAttributeName]]];
                                          
                                          [gedcomString addAttribute:NSLinkAttributeName value:url range:range];
                                      } else if ([attrs objectForKey:GCValueAttributeName]) {
                                          //nothing
                                      }
                                  }];
    
    return gedcomString;
}

- (void)setAttributedGedcomString:(NSAttributedString *)attributedGedcomString
{
    [self setGedcomString:[attributedGedcomString string]];
}

@end

@implementation GCObject (GCConvenienceMethods)

- (void)addAttributeWithType:(NSString *)type value:(GCValue *)value
{
    [[self mutableArrayValueForKey:@"properties"] addObject:[GCAttribute attributeWithType:type value:value]];
}

- (void)addRelationshipWithType:(NSString *)type target:(GCEntity *)target
{
    GCRelationship *relationship = [GCRelationship relationshipWithType:type];
    
    [[self mutableArrayValueForKey:@"properties"] addObject:relationship];
    
    [relationship setTarget:target];
}

- (void)addPropertyWithGedcomNode:(GCNode *)node
{
    [GCProperty propertyForObject:self withGedcomNode:node];
}

- (void)addPropertiesWithGedcomNodes:(NSOrderedSet *)nodes
{
    [nodes enumerateObjectsWithOptions:(NSEnumerationConcurrent) usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addPropertyWithGedcomNode:obj];
    }];
}

- (NSMutableSet *)propertiesSet
{
    return [self mutableSetValueForKey:@"properties"];
}

- (NSMutableArray *)propertiesArray
{
    return [self mutableArrayValueForKey:@"properties"];
}

@end

@implementation GCObject (GCCodingHelpers)

- (void)decodeProperties:(NSCoder *)aDecoder
{
    @synchronized(_propertyStore) {
        _propertyStore = [aDecoder decodeObjectForKey:@"propertyStore"];
    }
}

- (void)encodeProperties:(NSCoder *)aCoder
{
    @synchronized(_propertyStore) {
        [aCoder encodeObject:_propertyStore forKey:@"propertyStore"];
    }
}

@end

@implementation GCObject (GCValidationMethods)

BOOL validateValueTypeHelper(NSString *key, id value, Class type, NSError **error) {
    if (![value isKindOfClass:type]) {
        if (NULL != error) {
            *error = [NSError errorWithDomain:@"GCErrorDoman" 
                                         code:-1 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Value %@ is incorrect type for key %@ (should be %@)", value, key, type], NSLocalizedDescriptionKey,
                                               nil]];
        }
        return NO;
    } else {
        return YES;
    }
}

BOOL validateTargetTypeHelper(NSString *key, id target, Class type, NSError **error) {
    if (![target isKindOfClass:type]) {
        if (NULL != error) {
            *error = [NSError errorWithDomain:@"GCErrorDoman" 
                                         code:-1 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"Target %@ is incorrect type for key %@ (should be %@)", target, key, type], NSLocalizedDescriptionKey,
                                               nil]];
        }
        return NO;
    } else {
        return YES;
    }
}

BOOL validatePropertyHelper(NSString *key, GCProperty *property, GCTag *tag, NSError **error) {
    if ([tag objectClass] == [GCAttribute class]) {
        if ([(GCAttribute *)property value] == nil) {
            //TODO check if value is required
            return YES;
        } else if (!validateValueTypeHelper(key, [(GCAttribute *)property value], [tag valueType], error)) {
            return NO;
        }
    }
    
    if ([tag objectClass] == [GCRelationship class]) {
        //TODO 
        if (!validateValueTypeHelper(key, [(GCRelationship *)property target], [GCEntity class], error)) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)validateObject:(NSError **)outError
{
    for (id propertyKey in [self validProperties]) {
        GCTag *subTag = [[self gedTag] subTagWithName:propertyKey];
        
        NSInteger propertyCount = 0;
        
        if ([self allowsMultiplePropertiesOfType:propertyKey]) {
            propertyCount = [[self valueForKey:propertyKey] count];
            for (id property in [self valueForKey:propertyKey]) {
                validatePropertyHelper(propertyKey, property, subTag, outError);
            }
        } else {
            propertyCount = [self valueForKey:propertyKey] ? 1 : 0;
            
            validatePropertyHelper(propertyKey, [self valueForKey:propertyKey], subTag, outError);
        }
        
        GCAllowedOccurrences allowedOccurrences = [[self gedTag] allowedOccurrencesOfSubTag:subTag];
        
        if (propertyCount > allowedOccurrences.max) {
            if (NULL != outError) {
                *outError = [NSError errorWithDomain:@"GCErrorDoman" 
                                                code:-1 
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"Too many values for key %@", propertyKey], NSLocalizedDescriptionKey,
                                                      nil]];
            }
            
            return NO;
        }
        
        if (propertyCount < allowedOccurrences.min) {
            if (NULL != outError) {
                *outError = [NSError errorWithDomain:@"GCErrorDoman" 
                                                code:-1 
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"Too few values for key %@", propertyKey], NSLocalizedDescriptionKey,
                                                      nil]];
            }
            
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)validateValue:(id *)ioValue forKey:(NSString *)inKey error:(NSError **)outError
{
    GCTag *subTag = [[self gedTag] subTagWithName:inKey];
    
    validatePropertyHelper(inKey, [self valueForKey:inKey], subTag, outError);
    
    if ([self allowsMultiplePropertiesOfType:inKey]) {
        if ([[self valueForKey:inKey] count] + 1 > [[self gedTag] allowedOccurrencesOfSubTag:subTag].max) {
            if (NULL != outError) {
                *outError = [NSError errorWithDomain:@"GCErrorDoman" 
                                                code:-1 
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"Too many values for key %@", inKey], NSLocalizedDescriptionKey,
                                                      nil]];
            }
            return NO;
        }
    }
    
    return YES;
}

@end