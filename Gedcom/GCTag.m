//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"

@interface GCTag ()

- (id)initWithName:(NSString *)name 
          settings:(NSDictionary *)settings;

@end

@implementation GCTag {
	NSDictionary *_settings;
    
    NSOrderedSet *_cachedValidSubTags;
    NSDictionary *_cachedSubTagsByName;
    NSDictionary *_cachedSubTagsByCode;
    NSDictionary *_cachedOccurencesDicts;
    Class _cachedValueClass;
    Class _cachedObjectClass;
    NSString *_cachedTargetType;
}

#pragma mark Constants

const NSString *kTags = @"tags";
const NSString *kNameTags = @"nameTags";
const NSString *kValidSubTags = @"validSubTags";
const NSString *kRootTags = @"rootTags";
const NSString *kAliases = @"aliases";
const NSString *kReverseRelationshipTag = @"reverseRelationshipTag";
const NSString *kCode = @"code";
const NSString *kName = @"name";
const NSString *kVariants = @"variants";
const NSString *kObjectType = @"objectType";
const NSString *kValueType = @"valueType";
const NSString *kTargetType = @"target";

#pragma mark Setup

__strong static NSMutableDictionary *tagStore;
__strong static NSMutableDictionary *tagInfo;
__strong static NSDictionary *_tagsByName;

+ (void)setupTagStoreForKey:(NSString *)key
{
    NSMutableDictionary *tagDict = [tagInfo objectForKey:key];
    NSParameterAssert(tagDict);
    
    for (NSString *variantName in [tagDict objectForKey:kVariants]) {
        id variant = [tagInfo objectForKey:variantName];
        NSParameterAssert(variant);
        
        if ([tagDict objectForKey:kValidSubTags]) {
            NSMutableArray *_validSubTags = [variant objectForKey:kValidSubTags];
            if (_validSubTags == nil) {
                _validSubTags = [[tagDict objectForKey:kValidSubTags] mutableCopy];
            } else {
                [_validSubTags addObjectsFromArray:[tagDict objectForKey:kValidSubTags]];
            }
            
            [variant setObject:_validSubTags forKey:kValidSubTags];
        }
        if ([tagDict objectForKey:kValueType] && ![variant objectForKey:kValueType]) {
            [variant setObject:[tagDict objectForKey:kValueType] forKey:kValueType];
        }
        if (![tagStore objectForKey:variantName]) {
            [self setupTagStoreForKey:variantName];
        }
    }
    
    if ([tagDict objectForKey:kCode] != nil) {
        GCTag *tag = [[GCTag alloc] initWithName:key
                                        settings:tagDict];
        [tagStore setObject:tag 
                     forKey:key];
        [tagStore setObject:tag
                     forKey:[NSString stringWithFormat:@"%@:%@", [tagDict objectForKey:kObjectType], [tagDict objectForKey:kCode]]];
    }
    
    for (NSDictionary *subTag in [tagDict objectForKey:kValidSubTags]) {
        if (![tagStore objectForKey:[subTag objectForKey:kName]]) {
            [self setupTagStoreForKey:[subTag objectForKey:kName]];
        }
    }
}

+ (void)setupTagInfo
{
    static dispatch_once_t predTag = 0;
    
    dispatch_once(&predTag, ^{
        
        NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"tags" 
                                                                              ofType:@"json"];
        NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:jsonPath];
        
        NSError *err = nil;
        
        tagInfo = [NSJSONSerialization JSONObjectWithData:jsonData 
                                                  options:NSJSONReadingMutableContainers
                                                    error:&err];
        
        //NSLog(@"tagInfo: %@", tagInfo);
        NSAssert(tagInfo != nil, @"error: %@", err);
        
        tagStore = [NSMutableDictionary dictionaryWithCapacity:[tagInfo count]*2];
        [self setupTagStoreForKey:@"@rootObject"];
    });
}

+ (NSDictionary *)tagsByName
{
    if (!_tagsByName) {
        NSSet *keys = [tagStore keysOfEntriesWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(id key, id obj, BOOL *stop) {
            return !([key hasPrefix:@"@"] || [key rangeOfString:@":"].location != NSNotFound);
        }];
        
        NSMutableDictionary *tmpTags = [NSMutableDictionary dictionary];
        
        for (NSString *key in keys) {
            [tmpTags setObject:[tagStore objectForKey:key] forKey:key];
        }
        
        _tagsByName = [tmpTags copy];
    }
    
    return [_tagsByName copy];
}


#pragma mark Initialization

- (id)initWithName:(NSString *)name 
		 settings:(NSDictionary *)settings
{
    NSParameterAssert(name != nil);
    
    self = [super init];
    
    if (self) {
        _name = name;
        _settings = settings;
    }
    
    return self;    
}

#pragma mark Entry points

+ (GCTag *)tagNamed:(NSString *)name
{
    [self setupTagInfo];
    
    NSParameterAssert(name != nil);
    
    GCTag *tag = [tagStore objectForKey:name];
    
    if (tag == nil) {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidTagNameException"
														 reason:[NSString stringWithFormat:@"Invalid tag name '%@'", name]
													   userInfo:nil];
		@throw exception;
    }
    
    return tag;
}

+ (GCTag *)rootTagWithCode:(NSString *)code
{
    [self setupTagInfo];
    
    NSParameterAssert(code != nil);
    
    NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"headerRecord", @"HEAD",
                         @"submissionRecord", @"SUBN",
                         @"familyRecord", @"FAM",
                         @"individualRecord", @"INDI",
                         @"multimediaRecord", @"OBJE",
                         @"noteRecord", @"NOTE",
                         @"repositoryRecord", @"REPO",
                         @"sourceRecord", @"SOUR",
                         @"submitterRecord", @"SUBM",
                         @"trailer", @"TRLR",
                         nil];
    
    return [tagStore objectForKey:[tmp valueForKey:code]];
}

#pragma mark Subtags

- (void)buildSubTagCaches
{
    NSMutableDictionary *byCode = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSMutableDictionary dictionary], @"attribute",
                                   [NSMutableDictionary dictionary], @"relationship",
                                   nil];
    NSMutableDictionary *byName = [NSMutableDictionary dictionary];
    
    for (GCTag *subTag in [self validSubTags]) {
        NSString *typeKey = [[NSStringFromClass([subTag objectClass]) substringFromIndex:2] lowercaseString];
        
        [[byCode objectForKey:typeKey] setObject:subTag forKey:[subTag code]];
        [byName setObject:subTag forKey:[subTag name]];
    }
    
    _cachedSubTagsByCode = [byCode copy];
    _cachedSubTagsByName = [byName copy];
}

- (GCTag *)subTagWithCode:(NSString *)code type:(NSString *)type
{
    if ([code hasPrefix:@"_"]) {
        NSString *tagName = [NSString stringWithFormat:@"Custom %@ tag", code];
        if ([tagStore valueForKey:tagName]) {
            return [tagStore valueForKey:tagName];
        }
        GCTag *tag = [[GCTag alloc] initWithName:tagName
                                        settings:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  code, kCode,
                                                  @"stringValue", kValueType,
                                                  type, kObjectType,
                                                  [NSOrderedSet orderedSet], kValidSubTags,
                                                  nil]];
        NSLog(@"Created custom %@ tag: %@", code, tag);
        [tagStore setObject:tag forKey:tagName];
        
        return tag;
    }
    
    if (!_cachedSubTagsByCode) {
        [self buildSubTagCaches];
    }
    
    return [[_cachedSubTagsByCode objectForKey:type] objectForKey:code];
}

- (GCTag *)subTagWithName:(NSString *)name
{
    if (!_cachedSubTagsByName) {
        [self buildSubTagCaches];
    }
    
    return [_cachedSubTagsByName objectForKey:name];
}

- (BOOL)isValidSubTag:(GCTag *)tag
{
    return [tag isCustom] || [[self validSubTags] containsObject:tag];
}

- (GCAllowedOccurrences)allowedOccurrencesOfSubTag:(GCTag *)tag
{
    if ([tag isCustom]) {
        return (GCAllowedOccurrences){0, NSIntegerMax};
    }
    
    if ([_settings objectForKey:kValidSubTags] == nil) {
        return (GCAllowedOccurrences){0, 0};
    }
    
    if (!_cachedOccurencesDicts) {
        NSMutableDictionary *occurrencesDicts = [NSMutableDictionary dictionary];
        
        for (NSDictionary *valid in [_settings objectForKey:kValidSubTags]) {
            if ([[valid objectForKey:kName] hasPrefix:@"@"]) {
                for (NSString *variantName in [[tagInfo objectForKey:[valid objectForKey:kName]] objectForKey:kVariants]) {
                    NSDictionary *validDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                               variantName, kName, 
                                               [valid objectForKey:@"min"], @"min",
                                               [valid objectForKey:@"max"], @"max",
                                               nil];
                    [occurrencesDicts setObject:validDict forKey:variantName];
                }
            } else {
                [occurrencesDicts setObject:valid forKey:[valid objectForKey:kName]];
            }
        }
        
        _cachedOccurencesDicts = [occurrencesDicts copy];
    }
    
    NSDictionary *validDict = [_cachedOccurencesDicts objectForKey:[tag name]];
    
    NSParameterAssert(validDict);
    
    NSInteger min = [[validDict objectForKey:@"min"] integerValue];
    
    NSInteger max = [[validDict objectForKey:@"max"] isEqual:@"M"]
                  ? NSIntegerMax
                  : [[validDict objectForKey:@"max"] integerValue]
                  ;
	
    return (GCAllowedOccurrences){min, max};
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@ %@)", [super description], [self code], [self name]];
}
//COV_NF_END

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder setValue:_name forKey:@"tagName"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	return [GCTag tagNamed:[decoder decodeObjectForKey:@"tagName"]];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self; //safe, since GCTags are immutable
}

#pragma mark Objective-C properties

@synthesize name = _name;

- (NSString *)localizedName
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    return [frameworkBundle localizedStringForKey:_name value:_name table:@"Tags"];
}

- (NSString *)code
{
    return [_settings objectForKey:kCode];
}

- (Class)valueType
{
    if (!_cachedValueClass) {
        NSString *valueTypeString = [_settings objectForKey:kValueType];
        
        _cachedValueClass = NSClassFromString([NSString stringWithFormat:@"GC%@", [valueTypeString capitalizedString]]);
    }
    
	return _cachedValueClass;
}

- (Class)objectClass
{
    if (!_cachedObjectClass) {
        NSString *objectClassString = [_settings objectForKey:kObjectType];
        
        _cachedObjectClass = NSClassFromString([NSString stringWithFormat:@"GC%@", [objectClassString capitalizedString]]);
    }
    
	return _cachedObjectClass;
}

- (NSString *)targetType
{
    if (!_cachedTargetType) {
        _cachedTargetType = [_settings objectForKey:kTargetType];
    }
    
	return _cachedTargetType;
}

- (NSOrderedSet *)validSubTags
{
    if (!_cachedValidSubTags) {
        NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithCapacity:[[_settings objectForKey:kValidSubTags] count]];
        for (NSDictionary *valid in [_settings objectForKey:kValidSubTags]) {
            if ([[valid objectForKey:kName] hasPrefix:@"@"]) {
                for (NSString *variantName in [[tagInfo objectForKey:[valid objectForKey:kName]] objectForKey:kVariants]) {
                    [set addObject:[GCTag tagNamed:variantName]];                
                }
            } else {
                [set addObject:[GCTag tagNamed:[valid objectForKey:kName]]];
            }
        }
        _cachedValidSubTags = [set copy];
    }
    
    return _cachedValidSubTags;
}

- (GCTag *)reverseRelationshipTag
{
	NSString *name = [_settings objectForKey:kReverseRelationshipTag];
	
	if (name != nil) {
		return [GCTag tagNamed:name];
	} else {
		return nil;
	}
}

- (BOOL)isCustom
{
    return [_name hasPrefix:@"Custom "];
}

@end
