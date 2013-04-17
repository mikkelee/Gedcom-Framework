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
    
    NSDictionary *_cachedSubTagsByName;
    NSDictionary *_cachedSubTagsByCode;
    NSDictionary *_cachedSubTagsByGroup;
    NSDictionary *_cachedOccurencesDicts;
    NSArray *_multipleAllowedCache;
    NSArray *_onlySingleAllowedCache;
}

#pragma mark Constants

const NSString *kRootObject = @"@rootObject";

const NSString *kTagName = @"name";
const NSString *kPluralName = @"plural";
const NSString *kGroupName = @"groupName";

const NSString *kTagCode = @"code";

const NSString *kVariants = @"variants";

const NSString *kValidSubTags = @"validSubTags";

const NSString *kMin = @"min";
const NSString *kMax = @"max";

const NSString *kClassName = @"className";
const NSString *kObjectType = @"objectType";
const NSString *kValueType = @"valueType";
const NSString *kTargetType = @"target";

const NSString *kAllowsNilValue = @"allowsNil";
const NSString *kAllowedValues = @"allowedValues";

const NSString *kHasXref = @"hasXref";
const NSString *kHasValue = @"hasValue";

#pragma mark Initialization

__strong static NSMutableDictionary *_tagStore;
__strong static NSMutableDictionary *_tagInfo;
__strong static NSMutableDictionary *_singularToPlural;
__strong static NSMutableDictionary *_rootTagsByCode;

static dispatch_group_t _group;
static dispatch_queue_t _queue;

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
    
    NSAssert(_tagInfo != nil, @"error: %@", err);
    
    _group = dispatch_group_create();
    _queue = dispatch_queue_create("dk.kildekort.Gedcom.tagSetup", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(_group, _queue, ^{
        setupKey((NSString *)kRootObject);
    });
}

static inline void setupKey(NSString *key) {
    if (_tagStore[key]) {
        return;
    }
    
    NSMutableDictionary *tagDict = _tagInfo[key];
    assert(tagDict != nil);
    
    // store tags
    if (tagDict[kTagCode] != nil) {
        GCTag *tag = [[GCTag alloc] initWithName:key
                                        settings:tagDict];
        
        _tagStore[key] = tag;
        _tagStore[tagDict[kPluralName]] = tag;
        _tagStore[tagDict[kClassName]] = tag;
        
        if ([tagDict[kObjectType] isEqualToString:@"entity"]) {
            _rootTagsByCode[tagDict[kTagCode]] = tag;
        }
    }
    
    // set up variants
    for (NSDictionary *variant in tagDict[kVariants]) {
        if (variant[kGroupName]) {
            for (NSDictionary *subVariant in _tagInfo[variant[kGroupName]][kVariants]) {
                setupKey(subVariant[kTagName]);
            }
        } else {
            setupKey(variant[kTagName]);
        }
    }
    
    // set up subtags
    for (NSDictionary *subTag in tagDict[kValidSubTags]) {
        if (subTag[kGroupName]) {
            setupKey(subTag[kGroupName]);
        } else {
            setupKey(subTag[kTagName]);
        }
    }
}

static inline void expandSubtag(NSMutableOrderedSet *set, NSMutableDictionary *occurrencesDicts, NSDictionary *subtag) {
    if (subtag[kGroupName]) {
        for (NSDictionary *variant in _tagInfo[subtag[kGroupName]][kVariants]) {
            expandSubtag(set, occurrencesDicts, variant);
        }
    } else {
        [set addObject:[GCTag tagNamed:subtag[kTagName]]];
        occurrencesDicts[subtag[kTagName]] = subtag;
    }
}

- (void)_buildSubTagCaches
{
    NSMutableDictionary *occurrencesDicts = [NSMutableDictionary dictionary];
    NSMutableOrderedSet *subTags = [NSMutableOrderedSet orderedSetWithCapacity:[_settings[kValidSubTags] count]];
    for (NSDictionary *subtag in _settings[kValidSubTags]) {
        expandSubtag(subTags, occurrencesDicts, subtag);
    }
    
    _validSubTags = [subTags copy];
    _cachedOccurencesDicts = [occurrencesDicts copy];
    
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
    
    NSMutableDictionary *byGroup = [NSMutableDictionary dictionary];
    
    [_settings[kValidSubTags] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj[kGroupName];
        if (key) {
            NSString *variantGroupName = _tagInfo[key][kPluralName];
            for (NSDictionary *variant in _tagInfo[key][kVariants]) {
                if (!variant[kGroupName] && [self.validSubTags containsObject:[GCTag tagNamed:variant[kTagName]]]) {
                    if (!byGroup[variantGroupName]) {
                        byGroup[variantGroupName] = [NSMutableArray array];
                    }
                    [byGroup[variantGroupName] addObject:[GCTag tagNamed:variant[kTagName]]];
                }
            }
        }
    }];
    
    _cachedSubTagsByGroup = [byGroup copy];
}

- (id)initWithName:(NSString *)name settings:(NSDictionary *)settings
{
    GCParameterAssert(name);
    
    self = [super init];
    
    if (self) {
        _name = name;
        _settings = settings;
        
        _code = _settings[kTagCode];
        _isCustom = [_name hasPrefix:@"custom"];
        _localizedName = [[NSBundle bundleForClass:[self class]] localizedStringForKey:_name value:_name table:@"Tags"];
        _pluralName = _settings[kPluralName];
        
        // objectClass
        if (_isCustom) {
            _objectClass = NSClassFromString([NSString stringWithFormat:@"GCCustom%@", [_settings[kObjectType] capitalizedString]]);
        } else {
            _objectClass = NSClassFromString(_settings[kClassName]);
        }
        
        // for entities:
        _hasXref = _settings[kHasXref] != nil;
        _hasValue = _settings[kHasValue] != nil;
        
        // for attributes:
        _valueType = NSClassFromString([NSString stringWithFormat:@"GC%@", [_settings[kValueType] capitalizedString]]);
        _allowsNilValue = [_settings[kAllowsNilValue] boolValue];
        _allowedValues = [_settings[kAllowedValues] valueForKey:@"uppercaseString"];
        
        // for relationships:
        _targetType = _isCustom ? NSClassFromString(@"GCEntity") :  NSClassFromString([NSString stringWithFormat:@"GC%@Entity", [_settings[kTargetType] capitalizedString]]);
        
        dispatch_group_async(_group, _queue, ^{
            [self _buildSubTagCaches];
        });
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
                                        settings:@{kTagCode: code,
                                                  kTagName: tagName,
                                                  kPluralName: pluralName,
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

+ (GCTag *)tagWithClassName:(NSString *)className
{
    return _tagStore[className];
}

#pragma mark Subtags

- (GCTag *)subTagWithCode:(NSString *)code type:(NSString *)type
{
    if ([code hasPrefix:@"_"]) {
        @synchronized (self) {
            NSString *tagName = [NSString stringWithFormat:@"custom%@%@", code, [type capitalizedString]];
            NSString *pluralName = [NSString stringWithFormat:@"%@s", tagName];
            
            if ([_tagStore valueForKey:tagName]) {
                return [_tagStore valueForKey:tagName];
            }
            
            GCTag *tag = [[GCTag alloc] initWithName:tagName
                                            settings:@{kTagCode: code,
                                               kTagName: tagName,
                                             kPluralName: pluralName,
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
    return _cachedSubTagsByName[name];
}

- (NSArray *)subTagsInGroup:(NSString *)groupName
{
    return _cachedSubTagsByGroup[groupName];
}

- (BOOL)isValidSubTag:(GCTag *)tag
{
    return tag.isCustom || [self.validSubTags containsObject:tag];
}

- (GCAllowedOccurrences)allowedOccurrencesOfSubTag:(GCTag *)tag
{
    if (tag.isCustom) {
        return (GCAllowedOccurrences){0, NSUIntegerMax};
    }
    
    if (_settings[kValidSubTags] == nil) {
        return (GCAllowedOccurrences){0, 0};
    }
    
    NSDictionary *validDict = _cachedOccurencesDicts[tag.name];
    
    GCParameterAssert(validDict);
    
    NSInteger min = [validDict[kMin] unsignedIntegerValue];
    
    NSInteger max = [validDict[kMax] isEqual:@"M"]
                  ? NSUIntegerMax
                  : [validDict[kMax] unsignedIntegerValue]
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

@end
