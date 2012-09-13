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
    NSDictionary *_cachedSubTagsByGroup;
    NSDictionary *_cachedOccurencesDicts;
    Class _cachedValueClass;
    Class _cachedObjectClass;
    Class _cachedTargetType;
}

#pragma mark Constants

const NSString *kRootObject = @"@rootObject";
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
const NSString *kPlural = @"plural";

#pragma mark Setup

__strong static NSMutableDictionary *_tagStore;
__strong static NSMutableDictionary *_tagInfo;
__strong static NSDictionary *_tagsByName;
__strong static NSMutableDictionary *_singularToPlural;

+ (void)initialize
{
    _singularToPlural = [NSMutableDictionary dictionary];
    _tagStore = [NSMutableDictionary dictionaryWithCapacity:[_tagInfo count]*2];
}

+ (void)setupTagStoreForKey:(NSString *)key
{
    NSMutableDictionary *tagDict = _tagInfo[key];
    NSParameterAssert(tagDict);
    
    tagDict[kName] = key;
    
    if (!tagDict[kPlural]) {
        tagDict[kPlural] = [NSString stringWithFormat:@"%@s", [key hasPrefix:@"@"] ? [key substringFromIndex:1] : key];
    }
    _singularToPlural[[key hasPrefix:@"@"] ? [key substringFromIndex:1] : key] = tagDict[kPlural];
    
    for (NSString *variantName in tagDict[kVariants]) {
        id variant = _tagInfo[variantName];
        NSParameterAssert(variant);
        
        if (tagDict[kValidSubTags]) {
            NSMutableArray *_validSubTags = variant[kValidSubTags];
            if (_validSubTags == nil) {
                _validSubTags = [tagDict[kValidSubTags] mutableCopy];
            } else {
                [_validSubTags addObjectsFromArray:tagDict[kValidSubTags]];
            }
            
            variant[kValidSubTags] = _validSubTags;
        }
        if (tagDict[kValueType] && !variant[kValueType]) {
            variant[kValueType] = tagDict[kValueType];
        }
        if (!_tagStore[variantName]) {
            [self setupTagStoreForKey:variantName];
        }
    }
    
    if (tagDict[kCode] != nil) {
        GCTag *tag = [[GCTag alloc] initWithName:key
                                        settings:tagDict];
        _tagStore[key] = tag;
        _tagStore[tagDict[kPlural]] = tag;
        //tagStore[[NSString stringWithFormat:@"%@:%@", tagDict[kObjectType], tagDict[kCode]]] = tag;
    }
    
    for (NSDictionary *subTag in tagDict[kValidSubTags]) {
        if (!_tagStore[subTag[kName]]) {
            [self setupTagStoreForKey:subTag[kName]];
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
        
        _tagInfo = [NSJSONSerialization JSONObjectWithData:jsonData 
                                                  options:NSJSONReadingMutableContainers
                                                    error:&err];
        
        //NSLog(@"tagInfo: %@", tagInfo);
        NSAssert(_tagInfo != nil, @"error: %@", err);
        
        [self setupTagStoreForKey:(NSString *)kRootObject];
    });
}

+ (NSDictionary *)tagsByName
{
    if (!_tagsByName) {
        NSSet *keys = [_tagStore keysOfEntriesWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(id key, id obj, BOOL *stop) {
            return !([key hasPrefix:@"@"] || [key rangeOfString:@":"].location != NSNotFound);
        }];
        
        NSMutableDictionary *tmpTags = [NSMutableDictionary dictionary];
        
        for (NSString *key in keys) {
            tmpTags[key] = _tagStore[key];
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
    
    GCTag *tag = _tagStore[name];
    
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
    
    //TODO ??
    NSDictionary *tmp = @{@"HEAD": @"header",
                         @"SUBN": @"submission",
                         @"FAM": @"family",
                         @"INDI": @"individual",
                         @"OBJE": @"multimedia",
                         @"NOTE": @"note",
                         @"REPO": @"repository",
                         @"SOUR": @"source",
                         @"SUBM": @"submitter",
                         @"TRLR": @"trailer"};
    
    return _tagStore[[tmp valueForKey:code]];
}

#pragma mark Subtags

- (void)buildSubTagCaches
{
    NSMutableDictionary *byCode = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSMutableDictionary dictionary], @"attribute",
                                   [NSMutableDictionary dictionary], @"relationship",
                                   nil];
    NSMutableDictionary *byName = [NSMutableDictionary dictionary];
    NSMutableDictionary *byVariant = [NSMutableDictionary dictionary];
    
    for (GCTag *subTag in [self validSubTags]) {
        NSString *typeKey = [NSStringFromClass([subTag objectClass]) hasSuffix:@"Attribute"] ? @"attribute" : @"relationship";
        
        byCode[typeKey][[subTag code]] = subTag;
        byName[[subTag name]] = subTag;
        byName[[subTag pluralName]] = subTag;
    }
    
    [_tagInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *tagDict, BOOL *stop) {
        if ([key hasPrefix:@"@"]) {
            NSString *variantGroupName = tagDict[kPlural];
            
            for (NSString *variantName in tagDict[kVariants]) {
                if (![variantName hasPrefix:@"@"] && [[self validSubTags] containsObject:[GCTag tagNamed:variantName]]) {
                    if (!byVariant[variantGroupName]) {
                        byVariant[variantGroupName] = [NSMutableArray array];
                    }
                    [byVariant[variantGroupName] addObject:[GCTag tagNamed:variantName]];
                }
            }
            
            //byName[variantGroupName] = byName[tagDict[kName]];
        }
    }];
    
    _cachedSubTagsByCode = [byCode copy];
    _cachedSubTagsByName = [byName copy];
    _cachedSubTagsByGroup = [byVariant copy];
}

- (GCTag *)subTagWithCode:(NSString *)code type:(NSString *)type
{
    if ([code hasPrefix:@"_"]) {
        NSString *tagName = [NSString stringWithFormat:@"custom%@Tag", code];
        if ([_tagStore valueForKey:tagName]) {
            return [_tagStore valueForKey:tagName];
        }
        GCTag *tag = [[GCTag alloc] initWithName:tagName
                                        settings:@{kCode: code,
                                                  kValueType: @"string",
                                                  kObjectType: type,
                                                  kValidSubTags: [NSOrderedSet orderedSet]}];
        NSLog(@"Created custom%@Tag: %@", code, tag);
        _tagStore[tagName] = tag;
        
        return tag;
    }
    
    if (!_cachedSubTagsByCode) {
        [self buildSubTagCaches];
    }
    
    return _cachedSubTagsByCode[type][code];
}

- (GCTag *)subTagWithName:(NSString *)name
{
    if (!_cachedSubTagsByName) {
        [self buildSubTagCaches];
    }
    
    return _cachedSubTagsByName[name];
}

- (NSArray *)subTagsInGroup:(NSString *)groupName
{
    if (!_cachedSubTagsByGroup) {
        [self buildSubTagCaches];
    }
    
    return _cachedSubTagsByGroup[groupName];
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
    
    if (_settings[kValidSubTags] == nil) {
        return (GCAllowedOccurrences){0, 0};
    }
    
    if (!_cachedOccurencesDicts) {
        NSMutableDictionary *occurrencesDicts = [NSMutableDictionary dictionary];
        
        for (NSDictionary *valid in _settings[kValidSubTags]) {
            if ([valid[kName] hasPrefix:@"@"]) {
                for (NSString *variantName in _tagInfo[valid[kName]][kVariants]) {
                    NSDictionary *validDict = @{kName: variantName, 
                                               @"min": valid[@"min"],
                                               @"max": valid[@"max"]};
                    occurrencesDicts[variantName] = validDict;
                }
            } else {
                occurrencesDicts[valid[kName]] = valid;
            }
        }
        
        _cachedOccurencesDicts = [occurrencesDicts copy];
    }
    
    NSDictionary *validDict = _cachedOccurencesDicts[[tag name]];
    
    NSParameterAssert(validDict);
    
    NSInteger min = [validDict[@"min"] integerValue];
    
    NSInteger max = [validDict[@"max"] isEqual:@"M"]
                  ? NSIntegerMax
                  : [validDict[@"max"] integerValue]
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

- (NSString *)localizedName
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    return [frameworkBundle localizedStringForKey:_name value:_name table:@"Tags"];
}

- (NSString *)pluralName
{
    return _settings[kPlural];
}

- (NSString *)code
{
    return _settings[kCode];
}

- (Class)valueType
{
    if (!_cachedValueClass) {
        NSString *valueTypeString = _settings[kValueType];
        
        _cachedValueClass = NSClassFromString([NSString stringWithFormat:@"GC%@", [valueTypeString capitalizedString]]);
    }
    
	return _cachedValueClass;
}

- (Class)objectClass
{
    if (!_cachedObjectClass) {
        NSString *objectClassString = [NSString stringWithFormat:@"GC%@%@%@", [[[self name] substringToIndex:1] uppercaseString], [[self name] substringFromIndex:1], [_settings[kObjectType] capitalizedString]];
        
        _cachedObjectClass = NSClassFromString(objectClassString);
        
        //NSLog(@"objectClassString: %@ => %@", objectClassString, _cachedObjectClass);
    }
    
	return _cachedObjectClass;
}

- (Class)targetType
{
    if (!_cachedTargetType) {
        NSString *targetTypeString = _settings[kTargetType];
        
        _cachedTargetType = NSClassFromString([NSString stringWithFormat:@"GC%@Entity", [targetTypeString capitalizedString]]);
    }
    
	return _cachedTargetType;
}

- (NSOrderedSet *)validSubTags
{
    if (!_cachedValidSubTags) {
        NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithCapacity:[_settings[kValidSubTags] count]];
        for (NSDictionary *valid in _settings[kValidSubTags]) {
            BOOL isPlural = [valid[@"max"] isEqualToString:@"M"];
            
            if ([valid[kName] hasPrefix:@"@"]) {
                for (NSString *variantName in _tagInfo[valid[kName]][kVariants]) {
                    [set addObject:[GCTag tagNamed:isPlural ? _singularToPlural[variantName] : variantName]];
                }
            } else {
                [set addObject:[GCTag tagNamed:isPlural ? _singularToPlural[valid[kName]] : valid[kName]]];
            }
        }
        _cachedValidSubTags = [set copy];
    }
    
    return _cachedValidSubTags;
}

- (GCTag *)reverseRelationshipTag
{
	NSString *name = _settings[kReverseRelationshipTag];
	
	if (name != nil) {
		return [GCTag tagNamed:name];
	} else {
		return nil;
	}
}

- (BOOL)isCustom
{
    return [_name hasPrefix:@"custom"];
}

@end
