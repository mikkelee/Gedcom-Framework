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
    
    NSArray *_cachedValidSubTags;
    NSDictionary *_cachedSubTagsByName;
    NSDictionary *_cachedSubTagsByCode;
    NSDictionary *_cachedSubTagsByGroup;
    NSDictionary *_cachedOccurencesDicts;
    Class _cachedValueClass;
    Class _cachedObjectClass;
    Class _cachedTargetType;
    NSArray *_cachedAllowedValues;
    NSArray *_multipleAllowedCache;
    NSArray *_onlySingleAllowedCache;
}

#pragma mark Constants

const NSString *kRootObject = @"@rootObject";

const NSString *kName = @"name";
const NSString *kCode = @"code";

const NSString *kVariants = @"variants";

const NSString *kValidSubTags = @"validSubTags";
const NSString *kGroupName = @"groupName";
const NSString *kMin = @"min";
const NSString *kMax = @"max";

const NSString *kObjectType = @"objectType";
const NSString *kValueType = @"valueType";
const NSString *kAllowsNil = @"allowsNil";
const NSString *kAllowedValues = @"allowedValues";
const NSString *kTargetType = @"target";
const NSString *kPlural = @"plural";

const NSString *kHasXref = @"hasXref";
const NSString *kHasValue = @"hasValue";

#pragma mark Initialization

__strong static NSMutableDictionary *_tagStore;
__strong static NSMutableDictionary *_tagInfo;
__strong static NSMutableDictionary *_singularToPlural;
__strong static NSMutableDictionary *_rootTagsByCode;

static inline void setupKey(NSString *key) {
    if (_tagStore[key]) {
        return;
    }
    
    //NSLog(@"setupKey: %@", key);
    
    NSMutableDictionary *tagDict = _tagInfo[key];
    assert(tagDict != nil);
    
    // propagate info to variants
    for (NSDictionary *variant in tagDict[kVariants]) {
        if (variant[kGroupName]) {
            for (NSDictionary *subVariant in _tagInfo[variant[kGroupName]][kVariants]) {
                setupKey(subVariant[kName]);
            }
        } else {
            setupKey(variant[kName]);
        }
    }
    
    // store tags
    if (tagDict[kCode] != nil) {
        GCTag *tag = [[GCTag alloc] initWithName:key
                                        settings:tagDict];
        
        _tagStore[key] = tag;
        _tagStore[tagDict[kPlural]] = tag;
        
        if ([tagDict[kObjectType] isEqualToString:@"entity"]) {
            //NSLog(@"storing root tag: %@", tag);
            _rootTagsByCode[tagDict[kCode]] = tag;
        }
    }
    
    // set up subtags
    for (NSDictionary *subTag in tagDict[kValidSubTags]) {
        if (subTag[kGroupName]) {
            setupKey(subTag[kGroupName]);
        } else {
            setupKey(subTag[kName]);
        }
    }
}

+ (void)initialize
{
    _singularToPlural = [NSMutableDictionary dictionary];
    _tagStore = [NSMutableDictionary dictionaryWithCapacity:[_tagInfo count]*2];
    _rootTagsByCode = [NSMutableDictionary dictionaryWithCapacity:[_tagInfo count]*2];
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"tags"
                                                                          ofType:@"json"];
    NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:jsonPath];
    
    NSError *err = nil;
    
    _tagInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingMutableContainers
                                                 error:&err];
    
    //NSLog(@"tagInfo: %@", tagInfo);
    NSAssert(_tagInfo != nil, @"error: %@", err);
    
    setupKey((NSString *)kRootObject);
    
    //NSLog(@"_tagInfo: %@", _tagInfo);
    //NSLog(@"_tagStore: %@", _tagStore);
}

- (id)initWithName:(NSString *)name settings:(NSDictionary *)settings
{
    GCParameterAssert(name);
    
    self = [super init];
    
    if (self) {
        _name = name;
        _settings = settings;
        
        _code = _settings[kCode];
        _isCustom = [_name hasPrefix:@"custom"];
        _localizedName = [[NSBundle bundleForClass:[self class]] localizedStringForKey:_name value:_name table:@"Tags"];
        _pluralName = _settings[kPlural];
        
        // objectClass
        NSString *lookupName = self.name;
        if (self.isCustom) {
            lookupName = @"custom";
        }
        NSString *objectClassString = [NSString stringWithFormat:@"GC%@%@%@", [[lookupName substringToIndex:1] uppercaseString], [lookupName substringFromIndex:1], [_settings[kObjectType] capitalizedString]];
        _objectClass = NSClassFromString(objectClassString);
        
        // for entities:
        _hasXref = _settings[kHasXref] != nil;
        _hasValue = _settings[kHasValue] != nil;
        
        // for attributes:
        _valueType = NSClassFromString([NSString stringWithFormat:@"GC%@", [_settings[kValueType] capitalizedString]]);
        _allowsNilValue = [_settings[kAllowsNil] boolValue];
        _allowedValues = [_settings[kAllowedValues] valueForKey:@"uppercaseString"];
        
        // for relationships:
        _targetType = _isCustom ? NSClassFromString(@"GCEntity") :  NSClassFromString([NSString stringWithFormat:@"GC%@Entity", [_settings[kTargetType] capitalizedString]]);
    }
    
    return self;    
}

#pragma mark Entry points

+ (GCTag *)tagNamed:(NSString *)name
{
    GCParameterAssert(name);
    
    return _tagStore[name];
}

+ (GCTag *)rootTagWithCode:(NSString *)code
{
    GCParameterAssert(code);
    
    if ([code hasPrefix:@"_"]) {
        NSString *tagName = [NSString stringWithFormat:@"custom%@Entity", code];
        NSString *pluralName = [NSString stringWithFormat:@"%@s", tagName];
        
        if ([_tagStore valueForKey:tagName]) {
            return [_tagStore valueForKey:tagName];
        }
        GCTag *tag = [[GCTag alloc] initWithName:tagName
                                        settings:@{kCode: code,
                                                  kName: tagName,
                                                  kPlural: pluralName,
                                                  kHasValue: @(1),
                                                  kObjectType: @"entity",
                                                  kValidSubTags: [NSArray array]}];
        NSLog(@"Created %@: %@", tagName, tag);
        _rootTagsByCode[code] = tag;
        _tagStore[tagName] = tag;
        _tagStore[pluralName] = tag;
    }
    
    return _rootTagsByCode[code];
}

#pragma mark Subtags

- (void)_buildSubTagCaches
{
    NSMutableDictionary *byCode = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSMutableDictionary dictionary], @"attribute",
                                   [NSMutableDictionary dictionary], @"relationship",
                                   nil];
    NSMutableDictionary *byName = [NSMutableDictionary dictionary];
    
    for (GCTag *subTag in self.validSubTags) {
        NSString *typeKey = [NSStringFromClass(subTag.objectClass) hasSuffix:@"Attribute"] ? @"attribute" : @"relationship";
        
        byCode[typeKey][subTag.code] = subTag;
        byName[subTag.name] = subTag;
        byName[subTag.pluralName] = subTag;
    }
    
    _cachedSubTagsByCode = [byCode copy];
    _cachedSubTagsByName = [byName copy];
}

- (GCTag *)subTagWithCode:(NSString *)code type:(NSString *)type
{
    if (!_cachedSubTagsByCode) {
        [self _buildSubTagCaches];
    }
    
    if ([code hasPrefix:@"_"]) {
        @synchronized (self) {
            NSString *tagName = [NSString stringWithFormat:@"custom%@%@", code, [type capitalizedString]];
            NSString *pluralName = [NSString stringWithFormat:@"%@s", tagName];
            
            if ([_tagStore valueForKey:tagName]) {
                return [_tagStore valueForKey:tagName];
            }
            
            GCTag *tag = [[GCTag alloc] initWithName:tagName
                                            settings:@{kCode: code,
                                               kName: tagName,
                                             kPlural: pluralName,
                                          kValueType: @"string",
                                         kTargetType: @"entity",
                                         kObjectType: type,
                                       kValidSubTags: [NSArray array]}];
            NSLog(@"Created %@: %@", tagName, tag);
            _tagStore[tagName] = tag;
            _tagStore[pluralName] = tag;
            
            return tag;
        }
    }
    
    return _cachedSubTagsByCode[type][code];
}

- (GCTag *)subTagWithName:(NSString *)name
{
    if (!_cachedSubTagsByName) {
        [self _buildSubTagCaches];
    }
    
    return _cachedSubTagsByName[name];
}

- (NSArray *)subTagsInGroup:(NSString *)groupName
{
    if (!_cachedSubTagsByGroup) {
        NSMutableDictionary *byGroup = [NSMutableDictionary dictionary];
        
        [_settings[kValidSubTags] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = obj[kGroupName];
            if (key) {
                NSString *variantGroupName = _tagInfo[key][kPlural];
                for (NSDictionary *variant in _tagInfo[key][kVariants]) {
                    if (!variant[kGroupName] && [self.validSubTags containsObject:[GCTag tagNamed:variant[kName]]]) {
                        if (!byGroup[variantGroupName]) {
                            byGroup[variantGroupName] = [NSMutableArray array];
                        }
                        [byGroup[variantGroupName] addObject:[GCTag tagNamed:variant[kName]]];
                    }
                }
            }
        }];
        
        _cachedSubTagsByGroup = [byGroup copy];
    }
    
    return _cachedSubTagsByGroup[groupName];
}

- (BOOL)isValidSubTag:(GCTag *)tag
{
    return tag.isCustom || [self.validSubTags containsObject:tag];
}

static inline void expandOccurences(NSMutableDictionary *occurrencesDicts, NSDictionary *subtag) {
    if (subtag[kGroupName]) {
        for (NSDictionary *variant in _tagInfo[subtag[kGroupName]][kVariants]) {
            expandOccurences(occurrencesDicts, variant);
        }
    } else {
        occurrencesDicts[subtag[kName]] = subtag;
    }
}

- (GCAllowedOccurrences)allowedOccurrencesOfSubTag:(GCTag *)tag
{
    if (tag.isCustom) {
        return (GCAllowedOccurrences){0, NSIntegerMax};
    }
    
    if (_settings[kValidSubTags] == nil) {
        return (GCAllowedOccurrences){0, 0};
    }
    
    if (!_cachedOccurencesDicts) {
        NSMutableDictionary *occurrencesDicts = [NSMutableDictionary dictionary];
        
        for (NSDictionary *subtag in _settings[kValidSubTags]) {
            expandOccurences(occurrencesDicts, subtag);
        }
        
        @synchronized (self) {
            _cachedOccurencesDicts = [occurrencesDicts copy];
        }
    }
    
    NSDictionary *validDict = _cachedOccurencesDicts[tag.name];
    
    GCParameterAssert(validDict);
    
    NSInteger min = [validDict[kMin] integerValue];
    
    NSInteger max = [validDict[kMax] isEqual:@"M"]
                  ? NSIntegerMax
                  : [validDict[kMax] integerValue]
                  ;
	
    return (GCAllowedOccurrences){min, max};
}

- (BOOL)allowsMultipleOccurrencesOfSubTag:(GCTag *)tag
{
    if (!_onlySingleAllowedCache) {
        NSMutableArray *onlySingleAllowedCache = [NSMutableArray array];
        NSMutableArray *multipleAllowedCache = [NSMutableArray array];
        
        for (GCTag *t in self.validSubTags) {
            if ([self allowedOccurrencesOfSubTag:t].max > 1) {
                [multipleAllowedCache addObject:t];
            } else {
                [onlySingleAllowedCache addObject:t];
            }
        }
        
        @synchronized (self) {
            _onlySingleAllowedCache = [onlySingleAllowedCache copy];
            _multipleAllowedCache = [multipleAllowedCache copy];
        }
    }
    
    BOOL singleAllowed = [_onlySingleAllowedCache containsObject:tag];
    BOOL multipleAllowed = [_multipleAllowedCache containsObject:tag];
    
    if (singleAllowed) {
        return NO;
    } else if (multipleAllowed) {
        return YES;
    } else {
        //NSLog(@"Couldn't decide if multiple %@ were allowed on %@", tag, self);
        return [self allowedOccurrencesOfSubTag:tag].max > 1; // it's probably custom, let's look it up
    }
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@ %@ %@)", [super description], self.code, self.name, NSStringFromClass(self.objectClass)];
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

static inline void expandSubtag(NSMutableOrderedSet *set, NSDictionary *valid) {
    if (valid[kGroupName]) {
        for (NSDictionary *variant in _tagInfo[valid[kGroupName]][kVariants]) {
            expandSubtag(set, variant);
        }
    } else {
        [set addObject:[GCTag tagNamed:valid[kName]]];
    }
}

- (NSArray *)validSubTags
{
    if (!_cachedValidSubTags) {
        NSMutableOrderedSet *subTags = [NSMutableOrderedSet orderedSetWithCapacity:[_settings[kValidSubTags] count]];
        for (NSDictionary *valid in _settings[kValidSubTags]) {
            expandSubtag(subTags, valid);
        }
        _cachedValidSubTags = [subTags copy];
    }
    
    return _cachedValidSubTags;
}

@end
