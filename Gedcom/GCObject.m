
//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

#import "GCNode.h"

#import "GCContext.h"

#import "GCEntity.h"
#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCObject_internal.h"
#import "GCContext_internal.h"

#import "ValidationHelpers.h"

#import "GCObject+GCObjectKeyValueAdditions.h"

__strong static NSMutableDictionary *_validPropertiesByType;
__strong static NSDictionary *_defaultColors;

@implementation GCObject

//static const NSString *GCColorPreferenceKey = @"GCColorPreferenceKey";

#pragma mark Initialization and teardown

+ (void)initialize
{
    static dispatch_once_t predObjectInit = 0;
    dispatch_once(&predObjectInit, ^{
        @synchronized (_validPropertiesByType) {
            _validPropertiesByType = [NSMutableDictionary dictionary];
        }
        
        @synchronized (_defaultColors) {
            _defaultColors = @{
            GCLevelAttributeName : [NSColor redColor],
            GCXrefAttributeName : [NSColor blueColor],
            GCTagAttributeName : [NSColor darkGrayColor]
            };
        }
    });
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
    return NSOrderedSame;
}

- (BOOL)isEqualTo:(id)other
{
    return [self.gedcomString isEqualToString:[other gedcomString]];
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self _initWithType:[aDecoder decodeObjectForKey:@"type"]];
    
    if (self) {
        for (NSString *propertyType in self.validPropertyTypes) {
            [super setValue:[aDecoder decodeObjectForKey:propertyType] forKey:propertyType];
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
    
    for (GCObject *property in self.allProperties) {
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

- (NSArray *)orderedProperties
{
    NSMutableArray *orderedProperties = [NSMutableArray array];
    
    for (NSString *propertyType in self.validPropertyTypes) {
        if ([self _allowsMultipleOccurrencesOfPropertyType:propertyType]) {
            [orderedProperties addObjectsFromArray:[super valueForKey:propertyType]];
        } else {
            if ([self valueForKey:propertyType]) {
                [orderedProperties addObject:[super valueForKey:propertyType]];
            }
        }
    }
    
    [orderedProperties addObjectsFromArray:_customProperties];
    
	return orderedProperties;
}

- (NSArray *)subNodes
{
    NSMutableArray *subNodes = [NSMutableArray array];
    
    for (GCProperty *property in self.orderedProperties) {
        [subNodes addObject:property.gedcomNode];
    }
    
	return subNodes;
}

- (void)setSubNodes:(NSArray *)newSubNodes
{
    NSArray *originalProperties = [self.orderedProperties copy];
    
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
                [self.allProperties removeObject:originalProperties[curMarker]];
                curMarker++;
            }
        }
        
    }
    
    _isBuildingFromGedcom = NO;
    
    GCParameterAssert([self.allProperties count] == [newSubNodes count]);
}

- (NSString *)gedcomString
{
    return [self.gedcomNode gedcomString];
}

- (void)setGedcomString:(NSString *)gedcomString
{
    NSArray *nodes = [GCNode arrayOfNodesFromString:gedcomString];
    
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
        
        if (propertyCount > allowedOccurrences.max) {
            isValid &= NO;
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                         code:GCTooManyValuesError
                                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Too many values for key %@ on %@", propertyKey, self.type], NSAffectedObjectsErrorKey: self}]);
        }
        
        if (propertyCount < allowedOccurrences.min) {
            isValid &= NO;
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                         code:GCTooFewValuesError
                                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Too few values for key %@ on %@", propertyKey, self.type], NSAffectedObjectsErrorKey: self}]);
        }
    }
    
    if (!isValid && outError != NULL) {
        *outError = returnError;
    }
    
    return isValid;
}

@end