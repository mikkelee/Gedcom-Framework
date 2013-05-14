//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"

#import "Gedcom_internal.h"

@interface NSMapTable (GCSubscriptAdditions)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

@end

@implementation NSMapTable (GCSubscriptAdditions)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id)key
{
    return [self setObject:object forKey:key];
}

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

const NSString *kRootObject = @"!entity";

const NSString *kTagName = @"name";
const NSString *kPluralName = @"plural";
const NSString *kGroupName = @"groupName";

const NSString *kParent = @"parent";
const NSString *kTagCode = @"code";

const NSString *kVariants = @"variants";
const NSString *kSubClasses = @"subClasses";
const NSString *kSubClassName = @"subClassName";

const NSString *kValidSubTags = @"validSubTags";

const NSString *kMin = @"min";
const NSString *kMax = @"max";

const NSString *kClassName = @"className";
const NSString *kObjectType = @"objectType";
const NSString *kValueType = @"valueType";
const NSString *kTargetType = @"targetType";

const NSString *kAllowsNilValue = @"allowsNil";
const NSString *kAllowedValues = @"allowedValues";

const NSString *kTakesValue = @"takesValue";
const NSString *kHasReverse = @"hasReverse";
const NSString *kIsMain = @"isMain";

#pragma mark Initialization

__strong static NSMapTable *_tagStore;
__strong static NSMutableDictionary *_tagInfo;
__strong static NSMutableDictionary *_rootTagsByCode;

static dispatch_group_t _tagSetupGroup;
static dispatch_queue_t _tagSetupQueue;

+ (void)load
{
    _tagStore = [NSMapTable mapTableWithStrongToStrongObjects];
    _rootTagsByCode = [NSMutableDictionary dictionary];
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"tags"
                                                                          ofType:@"json"];
    NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:jsonPath];
    
    NSError *err = nil;
    
    _tagInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingMutableContainers
                                                 error:&err];
    
    NSAssert(_tagInfo != nil, @"error: %@", err);
    
    _tagSetupGroup = dispatch_group_create();
    _tagSetupQueue = dispatch_queue_create("dk.kildekort.Gedcom.tagSetup", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(_tagSetupGroup, _tagSetupQueue, ^{
        [_tagInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableDictionary *tagDict, BOOL *stop) {
            if (![tagDict[@"key"] hasPrefix:@"@"]) {
                GCTag *tag = [[GCTag alloc] initWithName:key
                                                settings:tagDict];
                
                _tagStore[key] = tag;
                _tagStore[tagDict[kPluralName]] = tag;
                _tagStore[NSClassFromString(tagDict[kClassName])] = tag;
                
                if (tagDict[kTagCode] && ([tagDict[kObjectType] isEqualToString:@"entity"] || [tagDict[kObjectType] isEqualToString:@"record"])) {
                    _rootTagsByCode[tagDict[kTagCode]] = tag;
                }
            }
        }];
    });
}

- (instancetype)parent
{
    return _tagStore[_settings[kParent]];
}

static inline void expandSubtag(NSMutableOrderedSet *set, NSMutableDictionary *occurrencesDicts, NSDictionary *subtag) {
    if (subtag[kGroupName]) {
        for (NSDictionary *variant in _tagInfo[subtag[kGroupName]][kVariants]) {
            expandSubtag(set, occurrencesDicts, variant);
        }
    } else if (subtag[kSubClassName]) {
        for (NSDictionary *subClass in _tagInfo[subtag[kSubClassName]][kSubClasses]) {
            expandSubtag(set, occurrencesDicts, subClass);
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
    
    if (self.parent) {
        for (NSDictionary *subtag in self.parent->_settings[kValidSubTags]) {
            expandSubtag(subTags, occurrencesDicts, subtag);
        }
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
        
        key = obj[kSubClassName];
        if (key) {
            NSString *variantGroupName = _tagInfo[key][kPluralName];
            for (NSDictionary *subClass in _tagInfo[key][kSubClasses]) {
                if (!subClass[kGroupName] && [self.validSubTags containsObject:[GCTag tagNamed:subClass[kTagName]]]) {
                    if (!byGroup[variantGroupName]) {
                        byGroup[variantGroupName] = [NSMutableArray array];
                    }
                    [byGroup[variantGroupName] addObject:[GCTag tagNamed:subClass[kTagName]]];
                }
            }
        }
    }];
    
    _cachedSubTagsByGroup = [byGroup copy];
}

- (instancetype)initWithName:(NSString *)name settings:(NSDictionary *)settings
{
    GCParameterAssert(name);
    
    self = [super init];
    
    if (self) {
        _name = name;
        _settings = settings;
        
        _code = _settings[kTagCode];
        _isCustom = [_name hasPrefix:@"custom"];
        _localizedName = GCLocalizedString(_name, @"Tags");
        _pluralName = _settings[kPluralName];
        
        // objectClass
        if (_isCustom) {
            _objectClass = NSClassFromString([NSString stringWithFormat:@"GCCustom%@", [_settings[kObjectType] capitalizedString]]);
        } else {
            _objectClass = NSClassFromString(_settings[kClassName]);
        }
        
        _type =
          [_settings[kObjectType] isEqualToString:@"entity"] ? GCTagTypeEntity
        : [_settings[kObjectType] isEqualToString:@"record"] ? GCTagTypeRecord
        : [_settings[kObjectType] isEqualToString:@"attribute"] ? GCTagTypeAttribute
        : [_settings[kObjectType] isEqualToString:@"relationship"] ? GCTagTypeRelationship
        : GCTagTypeUnknown;
        
        // for entities:
        _takesValue = [_settings[kTakesValue] boolValue];
        
        // for attributes:
        _valueType = NSClassFromString([NSString stringWithFormat:@"GC%@", [_settings[kValueType] capitalizedString]]);
        _allowsNilValue = [_settings[kAllowsNilValue] boolValue];
        _allowedValues = [_settings[kAllowedValues] valueForKey:@"uppercaseString"];
        
        // for relationships:
        _targetType = _isCustom ? NSClassFromString(@"GCRecord") :  NSClassFromString([NSString stringWithFormat:@"GC%@Record", [_settings[kTargetType] capitalizedString]]);
        _hasReverse = [_settings[kHasReverse] boolValue];
        _isMain = [_settings[kIsMain] boolValue];
        
        dispatch_async(_tagSetupQueue, ^{
            dispatch_group_wait(_tagSetupGroup, DISPATCH_TIME_FOREVER);
            [self _buildSubTagCaches];
        });
    }
    
    return self;    
}

#pragma mark Entry points

+ (GCTag *)tagNamed:(NSString *)name
{
    GCParameterAssert(name);
    
    dispatch_group_wait(_tagSetupGroup, DISPATCH_TIME_FOREVER);
    
    return _tagStore[name];
}

+ (GCTag *)rootTagWithCode:(NSString *)code
{
    GCParameterAssert(code);
    
    dispatch_group_wait(_tagSetupGroup, DISPATCH_TIME_FOREVER);
    
    if ([code hasPrefix:@"_"]) {
        NSString *className = @"GCCustomEntity";
        NSString *tagName = [NSString stringWithFormat:@"custom%@Entity", code];
        NSString *pluralName = [NSString stringWithFormat:@"%@s", tagName];
        
        if (_tagStore[tagName]) {
            return _tagStore[tagName];
        }
        
        GCTag *tag = [[GCTag alloc] initWithName:tagName
                                        settings:@{kTagCode: code,
                                                  kTagName: tagName,
                                                  kPluralName: pluralName,
                                                  kTakesValue: @(1),
                                                  kObjectType: @"entity",
                                                  kValidSubTags: [NSArray array]}];
        NSLog(@"Created %@: %@", tagName, tag);
        _rootTagsByCode[code] = tag;
        _tagStore[tagName] = tag;
        _tagStore[pluralName] = tag;
        _tagStore[NSClassFromString(className)] = tag;
    }
    
    return _rootTagsByCode[code];
}

+ (GCTag *)tagWithObjectClass:(Class)aClass
{
    GCParameterAssert(aClass);
    
    dispatch_group_wait(_tagSetupGroup, DISPATCH_TIME_FOREVER);
    
    return _tagStore[aClass];
}

+ (NSArray *)rootTags
{
    static dispatch_once_t onceToken;
    static NSArray *_rootTags = nil;
    dispatch_once(&onceToken, ^{
        NSArray *_rootKeys = @[ @"families", @"individuals", @"multimedias", @"notes", @"repositories", @"sources", @"submitters" ];
        
        NSMutableArray *rootTags = [NSMutableArray array];
        for (NSString *key in _rootKeys) {
            [rootTags addObject:_tagStore[key]];
        }
        
        _rootTags = [rootTags copy];
    });
    
    return _rootTags;
}

#pragma mark Subtags

- (GCTag *)subTagWithCode:(NSString *)code type:(GCTagType)type
{
    NSString *tagType = (type == GCTagTypeRelationship ? @"relationship" : @"attribute" ); //TODO check for others
    
    if ([code hasPrefix:@"_"]) {
        @synchronized (self) {
            NSString *className = [NSString stringWithFormat:@"GCCustom%@", [tagType capitalizedString]];
            NSString *tagName = [NSString stringWithFormat:@"custom%@%@", code, [tagType capitalizedString]];
            NSString *pluralName = [NSString stringWithFormat:@"%@s", tagName];
            
            if (_tagStore[tagName]) {
                return _tagStore[tagName];
            }
            
            GCTag *tag = [[GCTag alloc] initWithName:tagName
                                            settings:@{kTagCode: code,
                                            kTagName: tagName,
                                         kPluralName: pluralName,
                                          kValueType: @"string",
                                         kTargetType: @"record",
                                         kObjectType: tagType,
                                       kValidSubTags: [NSArray array]}];
            NSLog(@"Created %@: %@", tagName, tag);
            _tagStore[tagName] = tag;
            _tagStore[pluralName] = tag;
            _tagStore[NSClassFromString(className)] = tag;
            
            return tag;
        }
    }
    
    return _cachedSubTagsByCode[tagType][code];
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
    
    if (![self isValidSubTag:tag]) {
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

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	return [GCTag tagNamed:[decoder decodeObjectForKey:@"tagName"]];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self; //safe, since GCTags are immutable
}

@end
