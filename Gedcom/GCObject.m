
//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

#import "GCNodeParser.h"
#import "GCNode.h"

#import "GCContext.h"

#import "GCObject+GCGedcomLoadingAdditions.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

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

- (void)insertObject:(GCProperty *)prop inPropertiesAtIndex:(NSUInteger)index {
    GCTag *tag = [GCTag tagNamed:prop.type];
    
    if ([self.gedTag allowsMultipleOccurrencesOfSubTag:tag]) {
        [[self mutableArrayValueForKey:tag.pluralName] addObject:prop];
    } else {
        [self setValue:prop forKey:tag.name];
    }
}

- (void)removeObjectFromPropertiesAtIndex:(NSUInteger)index {
    GCProperty *prop = self.properties[index];
    
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
    
    for (GCProperty *property in self.properties) {
        [subNodes addObject:property.gedcomNode];
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
                                          NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@/%@",
                                                                                      @"xref",
                                                                                      [self.context name],
                                                                                      attrs[GCLinkAttributeName]]];
                                          
                                          [gedcomString addAttribute:NSLinkAttributeName value:url range:range];
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

@implementation GCObject (GCConvenienceMethods)

- (void)addPropertyWithGedcomNode:(GCNode *)node
{
    GCTag *tag = [self.gedTag subTagWithCode:node.gedTag type:([node valueIsXref] ? @"relationship" : @"attribute")];
    
    if (tag.isCustom) {
        if (![self.context _shouldHandleCustomTag:tag forNode:node onObject:self]) {
            return;
        }
    }
    
    (void)[[tag.objectClass alloc] initWithGedcomNode:node onObject:self];
}

- (void)addPropertiesWithGedcomNodes:(NSArray *)nodes
{
    for (id node in nodes) {
        [self addPropertyWithGedcomNode:node];
    }
}

@end

@implementation GCObject (GCValidationMethods)

- (BOOL)validateObject:(NSError **)outError
{
    //NSLog(@"validating: %@", self);
    
    BOOL isValid = YES;
    
    NSError *returnError = nil;
    
    NSSet *propertyKeys = [self.validPropertyTypes set];
    /*
     @synchronized (_propertyStore) {
     propertyKeys = [[NSSet setWithArray:[_propertyStore allKeys]] setByAddingObjectsFromSet:[self.validPropertyTypes set]];
     }*/
    
    for (NSString *propertyKey in propertyKeys) {
        GCTag *subTag = [GCTag tagNamed:propertyKey];
        
        NSInteger propertyCount = 0;
        
        if ([self _allowsMultipleOccurrencesOfPropertyType:propertyKey]) {
            propertyCount = [[self valueForKey:propertyKey] count];
            
            for (id property in [self valueForKey:propertyKey]) {
                NSError *err = nil;
                
                BOOL propertyValid = [property validateObject:&err];
                
                if (!propertyValid) {
                    isValid &= NO;
                    returnError = combineErrors(returnError, err);
                }
            }
        } else {
            propertyCount = [self valueForKey:propertyKey] ? 1 : 0;
            
            if (propertyCount) {
                NSError *err = nil;
                
                BOOL propertyValid = [[self valueForKey:propertyKey] validateObject:&err];
                
                if (!propertyValid) {
                    isValid &= NO;
                    returnError = combineErrors(returnError, err);
                }
            }
        }
        
        GCAllowedOccurrences allowedOccurrences = [self.gedTag allowedOccurrencesOfSubTag:subTag];
        
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        
        if (propertyCount > allowedOccurrences.max) {
            isValid &= NO;
            
            NSString *formatString = [frameworkBundle localizedStringForKey:@"Too many values for key %@ on %@"
                                                                      value:@"Too many values for key %@ on %@"
                                                                      table:@"Errors"];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, propertyKey, self.type],
                                       NSAffectedObjectsErrorKey: self
                                       };
            
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                         code:GCTooManyValuesError
                                                                     userInfo:userInfo]);
        }
        
        if (propertyCount < allowedOccurrences.min) {
            isValid &= NO;
            
            NSString *formatString = [frameworkBundle localizedStringForKey:@"Too few values for key %@ on %@"
                                                                      value:@"Too few values for key %@ on %@"
                                                                      table:@"Errors"];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, propertyKey, self.type],
                                       NSAffectedObjectsErrorKey: self
                                       };
            
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                         code:GCTooFewValuesError
                                                                     userInfo:userInfo]);
        }
    }
    
    if (!isValid && outError != NULL) {
        *outError = returnError;
    }
    
    return isValid;
}

@end