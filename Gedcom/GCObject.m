
//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject_internal.h"

#import "GCObject+GCConvenienceAdditions.h"

#import "GCNodeParser.h"
#import "GCNode.h"

#import <objc/runtime.h>
#import <objc/objc-class.h>

__strong static NSMutableDictionary *_validPropertiesByType;
__strong static NSDictionary *_defaultColors;

@implementation GCObject {
    NSMutableArray *_customProperties;
}

//static const NSString *GCColorPreferenceKey = @"GCColorPreferenceKey";

#pragma mark Initialization

+ (void)initialize
{
    _validPropertiesByType = [NSMutableDictionary dictionary];
    
    _defaultColors = @{
                       GCLevelAttributeName : [NSColor redColor],
                       GCXrefAttributeName : [NSColor blueColor],
                       GCTagAttributeName : [NSColor darkGrayColor]
                       };
}

//COV_NF_START
- (id)init
{
    NSLog(@"You must use -initWithType: to initialize a GCObject!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
//COV_NF_END

- (id)_initWithType:(NSString *)type
{
    self = [super init];
    
    if (self) {
        _gedTag = [GCTag tagNamed:type];
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
            NSMutableOrderedSet *valid = [NSMutableOrderedSet orderedSetWithCapacity:[_gedTag.validSubTags count]];
            
            for (GCTag *subTag in _gedTag.validSubTags) {
                if ([_gedTag allowedOccurrencesOfSubTag:subTag].max > 1) {
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
    return [_gedTag allowedOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (BOOL)_allowsMultipleOccurrencesOfPropertyType:(NSString *)type
{
    return [_gedTag allowsMultipleOccurrencesOfSubTag:[GCTag tagNamed:type]];
}

- (NSArray *)propertyTypesInGroup:(NSString *)groupName
{
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    for (GCTag *tag in [_gedTag subTagsInGroup:groupName]) {
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self _initWithType:[aDecoder decodeObjectForKey:@"type"]];
    
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

- (NSString *)type
{
    return _gedTag.name;
}

- (NSString *)localizedType
{
    return _gedTag.localizedName;
}

@dynamic rootObject;
@dynamic context;
@dynamic gedcomNode;
@dynamic displayValue;
@dynamic attributedDisplayValue;
@dynamic URL;

- (NSUndoManager *)undoManager
{
    return self.rootObject.undoManager;
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    NSLog(@"You override this method in your subclass!");
    [self doesNotRecognizeSelector:_cmd];
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

- (NSArray *)subNodes
{
    NSMutableArray *subNodes = [NSMutableArray array];
    
    for (id property in self.properties) {
        [subNodes addObject:[property valueForKey:@"gedcomNode"]];
    }
    
	return subNodes;
}

- (void)setSubNodes:(NSArray *)newSubNodes
{
    NSArray *originalProperties = [self.properties copy];
    
    NSArray *curSubNodes = self.subNodes;
    
    NSUInteger curMarker = 0;
    NSUInteger newMarker = 0;
    
    _isBuildingFromGedcom = YES;
    
    while (newMarker < [newSubNodes count]) {
        //NSLog(@"%ld,%ld", newMarker, curMarker);
        
        if (curMarker >= [curSubNodes count]) {
            //NSLog(@"INSERT %@", newSubNodes[newMarker]);
            [self addPropertyWithGedcomNode:newSubNodes[newMarker]];
            newMarker++;
        } else if ([curSubNodes[curMarker] isEqualTo:newSubNodes[newMarker]]) {
            //NSLog(@"SKIP; IDENTICAL");
            curMarker++;
            newMarker++;
        } else {
            
            NSUInteger nextIndex = [newSubNodes indexOfObject:curSubNodes[curMarker]
                                                      inRange:NSMakeRange(newMarker, [newSubNodes count]-(newMarker+1))];
            
            if (nextIndex != NSNotFound) {
                for (NSUInteger i = newMarker; i < nextIndex; i++) {
                    //NSLog(@"INSERT %@", newSubNodes[i]);
                    [self addPropertyWithGedcomNode:newSubNodes[i]];
                }
                newMarker = nextIndex+1;
            } else {
                //NSLog(@"DELETE %@", curSubNodes[curMarker]);
                [self.mutableProperties removeObject:originalProperties[curMarker]];
                curMarker++;
            }
        }
        
    }
    
    _isBuildingFromGedcom = NO;
    
    GCParameterAssert([self.properties count] == [newSubNodes count]);
}

- (NSString *)gedcomString
{
    return [self.gedcomNode gedcomString];
}

- (void)setGedcomString:(NSString *)gedcomString
{
    NSArray *nodes = [GCNodeParser arrayOfNodesFromString:gedcomString];
    
    GCParameterAssert([nodes count] == 1);
    
    GCNode *node = [nodes lastObject];
    
    GCParameterAssert([self.gedTag.code isEqualToString:node.gedTag]);
    
    self.gedcomNode = node;
}

- (NSAttributedString *)attributedGedcomString
{
    NSMutableAttributedString *gedcomString = [self.gedcomNode.attributedGedcomString mutableCopy];
    
    NSDictionary *colors = _defaultColors; //[[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)GCColorPreferenceKey];
    
    [gedcomString enumerateAttributesInRange:NSMakeRange(0, [gedcomString length])
                                     options:(kNilOptions)
                                  usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                      if (attrs[GCLevelAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:colors[GCLevelAttributeName] range:range];
                                      } else if (attrs[GCXrefAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:colors[GCXrefAttributeName] range:range];
                                      } else if (attrs[GCTagAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:colors[GCTagAttributeName] range:range];
                                      } else if (attrs[GCLinkAttributeName]) {
                                          [gedcomString addAttribute:NSLinkAttributeName value:self.URL range:range]; //TODO
                                      } else if (attrs[GCValueAttributeName]) {
                                          //nothing
                                      }
                                  }];
    
    return gedcomString;
}

- (void)setAttributedGedcomString:(NSAttributedString *)attributedGedcomString
{
    self.gedcomString = [attributedGedcomString string];
}

@end

@implementation GCObject (GCHelperAdditions)

+ (GCTag *)gedTag
{
    return [GCTag tagWithClassName:[self className]];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    Class cls = [self class];
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:cls];
    
    NSString *selName = NSStringFromSelector(sel);
    //NSLog(@"selName: %@", selName);
    
    IMP imp;
    Method method;
    
    if ([selName hasPrefix:@"insertObject"]) {
        
    } if ([selName hasPrefix:@"removeObject"]) {
        
    } if ([selName hasPrefix:@"countOf"]) {
        
    } if ([selName hasPrefix:@"mutable"]) {
        
    } if ([selName hasPrefix:@"objectIn"]) {
        
    } if ([selName hasPrefix:@"set"]) {
        // single setter
        
        NSString *propName = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:4] substringFromIndex:3] lowercaseString], [selName substringFromIndex:4]];
        propName = [propName substringToIndex:[propName length]-1];
        NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
        
        if (![[cls gedTag].validSubTags containsObject:[GCTag tagNamed:propName]]) {
            return NO;
        }
        
        //NSLog(@"**** Swizzling %@ :: %@ (%@ / %@) ****", cls, propName, selName, ivarName);
        
        Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
        
        // creating fake method first, so I can call it below for the undo manager:
        imp = imp_implementationWithBlock(^(id _s, id newObj) { return; });
        class_addMethod(cls, sel, imp, "v@:@");
        
        imp = imp_implementationWithBlock(^(id _s, id newObj) {
            id _ivar = object_getIvar(_s, ivar);
            
            NSString *formatString = [frameworkBundle localizedStringForKey:@"Undo %@"
                                                                      value:@"Undo %@"
                                                                      table:@"Misc"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [[[_s valueForKey:@"undoManager"] prepareWithInvocationTarget:_s] performSelector:sel withObject:_ivar];
#pragma clang diagnostic pop
            [[_s valueForKey:@"undoManager"] setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
            
            if (_ivar) {
                [_ivar setValue:nil forKey:@"describedObject"];
            }
            
            [[newObj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:newObj];
            
            [newObj setValue:_s forKey:@"describedObject"];
            
            NSParameterAssert(!newObj || [newObj valueForKey:@"describedObject"] == _s);
            
            object_setIvar(_s, ivar, newObj);
            
            //NSLog(@"!!swizz called!! ::: %@ : %@ ::: %@ => %@", cls, selName, _ivar, object_getIvar(_s, ivar));
    });
        
        method = class_getInstanceMethod(cls, sel);
    } else {
        // single getter
        
        NSString *propName = selName;
        NSString *ivarName = [NSString stringWithFormat:@"_%@", propName];
        
        if (![[cls gedTag].validSubTags containsObject:[GCTag tagNamed:propName]]) {
            return NO;
        }
        
        //NSLog(@"**** Swizzling %@ :: %@ (%@ / %@) ****", cls, propName, selName, ivarName);
        
        Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
        
        // creating fake method first, so I can call it below the undo manager or replace it outside the if/then:
        imp = imp_implementationWithBlock(^(id _s) { return nil; });
        class_addMethod(cls, sel, imp, "@@:");
        
        imp = imp_implementationWithBlock(^(id _s) {
            //NSLog(@"!!swizz called!! ::: %@ : %@ ::: => %@", cls, selName, object_getIvar(_s, ivar));
            
            return object_getIvar(_s, ivar);
        });

        method = class_getInstanceMethod(cls, sel);
    }
    
    if (imp) {
        //NSLog(@" -> adding %@", selName);
        
        method_setImplementation(method, imp);
        
        return YES;
    } else {
        return [super resolveInstanceMethod:sel];
    }
}

@end