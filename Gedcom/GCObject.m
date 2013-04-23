
//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

#import "GCObject+GCConvenienceAdditions.h"
#import "GCGedcomLoadingAdditions.h"
#import "GCGedcomAccessAdditions.h"

__strong static NSMutableDictionary *_validPropertiesByType;

@implementation GCObject {
    NSMutableArray *_customProperties;
}

//static const NSString *GCColorPreferenceKey = @"GCColorPreferenceKey";

#pragma mark Initialization

+ (void)initialize
{
    _validPropertiesByType = [NSMutableDictionary dictionary];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _customProperties = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark GCProperty access

- (NSOrderedSet *)validPropertyTypes
{
    @synchronized(_validPropertiesByType) {
        NSOrderedSet *_validProperties = _validPropertiesByType[self.type];
        
        if (!_validProperties) {
            NSMutableOrderedSet *valid = [NSMutableOrderedSet orderedSetWithCapacity:[self.gedTag.validSubTags count]];
            
            for (GCTag *subTag in self.gedTag.validSubTags) {
                if ([self.gedTag allowedOccurrencesOfSubTag:subTag].max > 1) {
                    [valid addObject:subTag.pluralName];
                } else {
                    [valid addObject:subTag.name];
                }
            }
            
            _validProperties = [valid copy];
            
            _validPropertiesByType[self.type] = _validProperties;
        }
        
        return _validProperties;
    }
}

- (GCAllowedOccurrences)allowedOccurrencesOfPropertyType:(NSString *)type
{
    return [self.gedTag allowedOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (BOOL)_allowsMultipleOccurrencesOfPropertyType:(NSString *)type
{
    return [self.gedTag allowsMultipleOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (NSArray *)propertyTypesInGroup:(NSString *)groupName
{
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    for (GCTag *tag in [self.gedTag subTagsInGroup:groupName]) {
        [propertyTypes addObject:tag.pluralName];
    }
    
    return [propertyTypes count] > 0 ? [propertyTypes copy] : nil;
}

#pragma mark Comparison & equality

- (NSComparisonResult)compare:(id)other
{
    //subclasses override to get actual result.
    NSParameterAssert([self class] == [other class]);
    return NSOrderedSame;
}

- (BOOL)isEqualTo:(GCObject *)other
{
    return [self.gedcomString isEqualToString:other.gedcomString];
}

#pragma mark NSCoding conformance

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        for (NSString *propertyType in self.validPropertyTypes) {
            id obj = [aDecoder decodeObjectForKey:propertyType];
            if (obj) {
                [super setValue:obj forKey:propertyType];
            }
        }
        @synchronized(_customProperties) {
            _customProperties = [aDecoder decodeObjectForKey:@"customProperties"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.type forKey:@"type"];
    for (NSString *propertyType in self.validPropertyTypes) {
        [aCoder encodeObject:[super valueForKey:propertyType] forKey:propertyType];
    }
    @synchronized(_customProperties) {
        [aCoder encodeObject:_customProperties forKey:@"customProperties"];
    }
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSLog(@"You must override this method in your subclass!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)_propertyDescriptionWithIndent:(NSUInteger)level
{
    NSMutableString *out = [NSMutableString string];
    
    for (GCObject *property in self.properties) {
        [out appendString:[property descriptionWithIndent:level+1]];
    }
    
    return out;
}
//COV_NF_END

#pragma mark Objective-C properties

+ (GCTag *)gedTag
{
	return [GCTag tagWithClassName:[self className]];
}

- (GCTag *)gedTag
{
    return [GCTag tagWithClassName:[self className]];
}

- (NSString *)type
{
    return self.gedTag.name;
}

- (NSString *)localizedType
{
    return self.gedTag.localizedName;
}

@dynamic rootObject;
@dynamic context;
@dynamic URL;

- (NSUndoManager *)undoManager
{
    return self.rootObject.undoManager;
}

- (NSArray *)properties
{
    NSMutableArray *properties = [NSMutableArray array];
    
    for (NSString *propertyType in self.validPropertyTypes) {
        if ([self _allowsMultipleOccurrencesOfPropertyType:propertyType]) {
            [properties addObjectsFromArray:[super valueForKey:propertyType]];
        } else {
            if ([self valueForKey:propertyType]) {
                [properties addObject:[super valueForKey:propertyType]];
            }
        }
    }
    
    [properties addObjectsFromArray:_customProperties];
    
	return [properties copy];
}

- (NSMutableArray *)mutableProperties
{
    return [self mutableArrayValueForKey:@"properties"];
}

- (NSUInteger)countOfProperties
{
    return [self.properties count];
}

- (id)objectInPropertiesAtIndex:(NSUInteger)index {
    return [self.properties objectAtIndex:index];
}

- (void)insertObject:(GCObject *)prop inPropertiesAtIndex:(NSUInteger)index {
    GCTag *tag = [GCTag tagNamed:prop.type];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] addObject:prop];
    } else {
        [self setValue:prop forKey:tag.name];
    }
}

- (void)removeObjectFromPropertiesAtIndex:(NSUInteger)index {
    GCObject *prop = self.properties[index];
    
    GCTag *tag = [GCTag tagNamed:prop.type];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] removeObject:prop];
    } else {
        [self setValue:nil forKey:tag.name];
    }
}

- (NSMutableArray *)mutableCustomProperties {
    return [self mutableArrayValueForKey:@"customProperties"];
}

- (NSUInteger)countOfCustomProperties
{
    return [_customProperties count];
}

- (id)objectInCustomPropertiesAtIndex:(NSUInteger)index {
    return [_customProperties objectAtIndex:index];
}

- (void)insertObject:(GCObject *)obj inCustomPropertiesAtIndex:(NSUInteger)index {
    [obj setValue:self forKey:@"describedObject"];
    [_customProperties insertObject:obj atIndex:index];
}

- (void)removeObjectFromCustomPropertiesAtIndex:(NSUInteger)index {
    [_customProperties[index] setValue:nil forKey:@"describedObject"];
    [_customProperties removeObjectAtIndex:index];
}

@end

#import <objc/runtime.h>

@implementation GCObject (GCHelperAdditions)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    @synchronized (self) {
        Class cls = [self class];
        
        NSBundle *frameworkBundle = [NSBundle bundleForClass:cls];
        
        NSString *formatString = [frameworkBundle localizedStringForKey:@"Undo %@"
                                                                  value:@"Undo %@"
                                                                  table:@"Misc"];
        
        NSString *selName = NSStringFromSelector(sel);
        
        //NSLog(@"%@ selName: %@", [self className], selName);
        
        BOOL didResolve = NO;
        
        if ([selName hasPrefix:@"insertObject"]) {
            
            // indexed mutable object insert
            
            NSString *propName = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:16] substringFromIndex:15] lowercaseString], [[selName substringFromIndex:16] substringToIndex:[selName length]-(16+8)]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
            
            GCTag *subtag = [GCTag tagNamed:propName];
            if ([[cls gedTag].validSubTags containsObject:subtag] && [[cls gedTag] allowsMultipleOccurrencesOfSubTag:subtag]) {
                
                NSString *reverseSelName = [NSString stringWithFormat:@"removeObjectFrom%@%@AtIndex:", [[propName substringToIndex:1] uppercaseString], [propName substringFromIndex:1]];
                SEL reverseSel = NSSelectorFromString(reverseSelName);
                
                //NSLog(@"**** Swizzling %@ :: %@/%@ (%@ / %@) ****", cls, selName, reverseSelName, propName, ivarName);
                
                Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
                
                // creating fake method first, so I can call it below for the undo manager:
                IMP imp = imp_implementationWithBlock(^(GCObject *_s, id newObj, NSUInteger index) { return; });
                class_addMethod(cls, sel, imp, "v@:@I");
                
                imp = imp_implementationWithBlock(^(GCObject *_s, id newObj, NSUInteger index) {
                    NSMutableArray *_ivar = object_getIvar(_s, ivar);
                    
                    if ([newObj valueForKey:@"describedObject"] == _s) {
                        return;
                    }
                    
                    if (!_s->_isBuildingFromGedcom) {
                        NSUndoManager *uM = [_s valueForKey:@"undoManager"];
                        @synchronized (uM) {
                            [uM beginUndoGrouping];
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_s methodSignatureForSelector:reverseSel]];
                            [invocation setSelector:reverseSel];
                            [invocation setTarget:[uM prepareWithInvocationTarget:_s]];
                            [invocation setArgument:&index atIndex:2];
                            [invocation invoke];
                            [uM setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
                            [uM endUndoGrouping];
                        }
                    }
                    
                    if ([newObj valueForKey:@"describedObject"]) {
                        [((GCObject *)[newObj valueForKey:@"describedObject"]).mutableProperties removeObject:newObj];
                    }
                    
                    [newObj setValue:_s forKey:@"describedObject"];
                    
                    [_ivar insertObject:newObj atIndex:index];
                });
                
                Method method = class_getInstanceMethod(cls, sel);
                
                method_setImplementation(method, imp);
                
                didResolve = YES;
            }
            
        } else if ([selName hasPrefix:@"removeObjectFrom"]) {
            
            // indexed mutable object remove
            
            NSString *propName = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:17] substringFromIndex:16] lowercaseString], [[selName substringFromIndex:17] substringToIndex:[selName length]-(17+8)]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
            
            GCTag *subtag = [GCTag tagNamed:propName];
            if ([[cls gedTag].validSubTags containsObject:subtag] && [[cls gedTag] allowsMultipleOccurrencesOfSubTag:subtag]) {
                
                NSString *reverseSelName = [NSString stringWithFormat:@"insertObject:in%@%@AtIndex:", [[propName substringToIndex:1] uppercaseString], [propName substringFromIndex:1]];
                SEL reverseSel = NSSelectorFromString(reverseSelName);
                
                //NSLog(@"**** Swizzling %@ :: %@/%@ (%@ / %@) ****", cls, selName, reverseSelName, propName, ivarName);
                
                Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
                
                // creating fake method first, so I can call it below for the undo manager:
                IMP imp = imp_implementationWithBlock(^(GCObject *_s, NSUInteger index) { return; });
                class_addMethod(cls, sel, imp, "v@:I");
                
                imp = imp_implementationWithBlock(^(GCObject *_s, NSUInteger index) {
                    NSMutableArray *_ivar = object_getIvar(_s, ivar);
                    
                    if (!((GCObject *)_s)->_isBuildingFromGedcom) {
                        NSUndoManager *uM = [_s valueForKey:@"undoManager"];
                        @synchronized (uM) {
                            [uM beginUndoGrouping];
                            id obj = _ivar[index];
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_s methodSignatureForSelector:reverseSel]];
                            [invocation setSelector:reverseSel];
                            [invocation setTarget:[uM prepareWithInvocationTarget:_s]];
                            [invocation setArgument:&obj atIndex:2];
                            [invocation setArgument:&index atIndex:3];
                            [invocation invoke];
                            [uM setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
                            [uM endUndoGrouping];
                        }
                    }
                    
                    [((GCObject *)_ivar[index]) setValue:nil forKey:@"describedObject"];
                    
                    [_ivar removeObjectAtIndex:index];
                });
                
                Method method = class_getInstanceMethod(cls, sel);
                
                method_setImplementation(method, imp);
                
                didResolve = YES;
            }
            
        } else if ([selName hasPrefix:@"objectIn"]) {
            
            // indexed mutable object get
            
            NSString *propName = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:9] substringFromIndex:8] lowercaseString], [[selName substringFromIndex:9] substringToIndex:[selName length]-(9+8)]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
            
            Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
            
            GCTag *subtag = [GCTag tagNamed:propName];
            if ([[cls gedTag].validSubTags containsObject:subtag] && [[cls gedTag] allowsMultipleOccurrencesOfSubTag:subtag]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@) ****", cls, selName, propName);
                
                IMP imp = imp_implementationWithBlock(^(GCObject *_s, NSUInteger index) {
                    return [object_getIvar(_s, ivar) objectAtIndex:index];
                });
                
                didResolve = class_addMethod(cls, sel, imp, "@@:I");
            }
            
        } else if ([selName hasPrefix:@"countOf"]) {
            
            // indexed mutable count
            
            NSString *propName = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:8] substringFromIndex:7] lowercaseString], [selName substringFromIndex:8]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
            
            Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
            
            GCTag *subtag = [GCTag tagNamed:propName];
            if ([[cls gedTag].validSubTags containsObject:subtag] && [[cls gedTag] allowsMultipleOccurrencesOfSubTag:subtag]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@) ****", cls, selName, propName);
                
                IMP imp = imp_implementationWithBlock(^(GCObject *_s) {
                    return [object_getIvar(_s, ivar) count];
                });
                
                didResolve = class_addMethod(cls, sel, imp, "I@:");
            }
            
        } else if ([selName hasPrefix:@"set"]) {
            
            // single setter
            
            NSString *propName = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:4] substringFromIndex:3] lowercaseString], [selName substringFromIndex:4]];
            propName = [propName substringToIndex:[propName length]-1];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
            
            GCTag *subtag = [GCTag tagNamed:propName];
            if ([[cls gedTag].validSubTags containsObject:subtag] && ![[cls gedTag] allowsMultipleOccurrencesOfSubTag:subtag]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@ / %@) ****", cls, selName, propName, ivarName);
                
                Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
                
                // creating fake method first, so I can call it below for the undo manager:
                IMP imp = imp_implementationWithBlock(^(id _s, id newObj) { return; });
                class_addMethod(cls, sel, imp, "v@:@");
                
                imp = imp_implementationWithBlock(^(GCObject *_s, id newObj) {
                    id _ivar = object_getIvar(_s, ivar);
                    
                    if (!_s->_isBuildingFromGedcom) {
                        NSUndoManager *uM = [_s valueForKey:@"undoManager"];
                        @synchronized (uM) {
                            [uM beginUndoGrouping];
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_s methodSignatureForSelector:sel]];
                            [invocation setSelector:sel];
                            [invocation setTarget:[uM prepareWithInvocationTarget:_s]];
                            [invocation setArgument:&_ivar atIndex:2];
                            [invocation invoke];
                            [uM setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
                            [uM endUndoGrouping];
                        }
                    }
                    
                    if (_ivar) {
                        [_ivar setValue:nil forKey:@"describedObject"];
                    }
                    
                    [[newObj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:newObj];
                    
                    [newObj setValue:_s forKey:@"describedObject"];
                    
                    NSParameterAssert(!newObj || [newObj valueForKey:@"describedObject"] == _s);
                    
                    object_setIvar(_s, ivar, newObj);
                    
                    //NSLog(@"!!swizz called!! ::: %@ : %@ ::: %@ => %@", cls, selName, _ivar, object_getIvar(_s, ivar));
                });
                
                Method method = class_getInstanceMethod(cls, sel);
                
                method_setImplementation(method, imp);
                
                didResolve = YES;
            }
            
            
        } else {
            
            // getter
            
            NSString *propName = selName;
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
            
            Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
            
            GCTag *subtag = [GCTag tagNamed:propName];
            if ([[cls gedTag].validSubTags containsObject:subtag]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@ / %@) ****", cls, selName, propName, ivarName);
                
                IMP imp = imp_implementationWithBlock(^(id _s) {
                    //NSLog(@"!!swizz called!! ::: %@ : %@ ::: => %@", cls, selName, object_getIvar(_s, ivar));
                    
                    return object_getIvar(_s, ivar);
                });
                
                didResolve = class_addMethod(cls, sel, imp, "@@:");
            }
        }
        
        if (didResolve) {
            //NSLog(@"%@ -> added %@", [self className], selName);
            
            return YES;
        } else {
            return [super resolveInstanceMethod:sel];
        }
    }
}

@end