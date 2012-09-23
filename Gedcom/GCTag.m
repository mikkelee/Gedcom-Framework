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
const NSString *kTargetType = @"target";
const NSString *kReverseRelationshipTag = @"reverseRelationshipTag";
const NSString *kPlural = @"plural";

#pragma mark Initialization

__strong static NSMutableDictionary *_tagStore;
__strong static NSMutableDictionary *_tagInfo;
__strong static NSDictionary *_tagsByName;
__strong static NSMutableDictionary *_singularToPlural;
__strong static NSMutableDictionary *_rootTagsByCode;

// Propagate info from sourceDict to tagInfo[variantKey] where applicable
static inline void propagate(NSString *variantKey, NSDictionary *sourceDict) {
    id variantDict = _tagInfo[variantKey];
    assert(variantDict != nil);
    
    if (sourceDict[kValidSubTags]) {
        NSMutableArray *validSubTags = variantDict[kValidSubTags];
        
        if (validSubTags == nil) {
            validSubTags = [sourceDict[kValidSubTags] mutableCopy];
        } else {
            [sourceDict[kValidSubTags] enumerateObjectsWithOptions:(kNilOptions) usingBlock:^(NSDictionary *subTag, NSUInteger idx, BOOL *stop) {
                BOOL subTagExists = NO;
                
                for (NSDictionary *existingTag in validSubTags) {
                    subTagExists = [existingTag[kName] isEqualToString:subTag[kName]] || [existingTag[kGroupName] isEqualToString:subTag[kGroupName]];
                    *stop = subTagExists;
                }
                
                if (!subTagExists) {
                    [validSubTags addObject:subTag];
                }
            }];
        }
        
        variantDict[kValidSubTags] = validSubTags;
    }
    
    if (sourceDict[kValueType] && !variantDict[kValueType]) {
        variantDict[kValueType] = sourceDict[kValueType];
    }
    
    if (sourceDict[kObjectType] && !variantDict[kObjectType]) {
        variantDict[kObjectType] = sourceDict[kObjectType];
    }
}

static inline void setupKey(NSString *key) {
    if (_tagStore[key]) {
        return;
    }
    
    //NSLog(@"setupKey: %@", key);
    
    NSMutableDictionary *tagDict = _tagInfo[key];
    assert(tagDict != nil);
    
    // name
    tagDict[kName] = [key hasPrefix:@"@"] ? [key substringFromIndex:1] : key;
    
    // pluralName
    if (!tagDict[kPlural]) {
        tagDict[kPlural] = [NSString stringWithFormat:@"%@s", tagDict[kName]];
    }
    _singularToPlural[tagDict[kName]] = tagDict[kPlural];
    
    // propagate info to variants
    for (NSDictionary *variant in tagDict[kVariants]) {
        if (variant[kGroupName]) {
            for (NSDictionary *subVariant in _tagInfo[variant[kGroupName]][kVariants]) {
                propagate(subVariant[kName], tagDict);
                
                setupKey(subVariant[kName]);
            }
        } else {
            propagate(variant[kName], tagDict);
            
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
    NSParameterAssert(name);
    
    GCTag *tag = _tagStore[name];
    
    if (tag == nil) {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidTagNameException"
														 reason:[NSString stringWithFormat:@"Invalid tag name '%@'", name]
													   userInfo:nil];
		@throw exception;
    }
    
    return tag;
}

+ (NSDictionary *)tagsByName
{
    if (!_tagsByName) {
        NSSet *keys = [_tagStore keysOfEntriesWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(NSString *key, GCTag *tag, BOOL *stop) {
            return ![key hasPrefix:@"@"] && !tag.isCustom;
        }];
        
        NSMutableDictionary *tmpTags = [NSMutableDictionary dictionary];
        
        for (NSString *key in keys) {
            tmpTags[key] = _tagStore[key];
        }
        
        _tagsByName = [tmpTags copy];
    }
    
    return [_tagsByName copy];
}

+ (GCTag *)rootTagWithCode:(NSString *)code
{
    NSParameterAssert(code != nil);
    
    if ([code hasPrefix:@"_"]) {
        NSString *tagName = [NSString stringWithFormat:@"custom%@Entity", code];
        if ([_tagStore valueForKey:tagName]) {
            return [_tagStore valueForKey:tagName];
        }
        GCTag *tag = [[GCTag alloc] initWithName:tagName
                                        settings:@{kCode: code,
                                                  kName: tagName,
                                                  kPlural: [NSString stringWithFormat:@"%@s", tagName],
                                                  kObjectType: @"entity",
                                                  kValidSubTags: [NSArray array]}];
        NSLog(@"Created %@: %@", tagName, tag);
        _rootTagsByCode[code] = tag;
        _tagStore[tagName] = tag;
    }
    
    return _rootTagsByCode[code];
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
    
    for (GCTag *subTag in self.validSubTags) {
        NSString *typeKey = [NSStringFromClass(subTag.objectClass) hasSuffix:@"Attribute"] ? @"attribute" : @"relationship";
        
        byCode[typeKey][subTag.code] = subTag;
        byName[subTag.name] = subTag;
        byName[subTag.pluralName] = subTag;
    }
    
    [_tagInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *tagDict, BOOL *stop) {
        if ([key hasPrefix:@"@"]) {
            NSString *variantGroupName = tagDict[kPlural];
            
            for (NSDictionary *variant in tagDict[kVariants]) {
                if (!variant[kGroupName] && [self.validSubTags containsObject:[GCTag tagNamed:variant[kName]]]) {
                    if (!byVariant[variantGroupName]) {
                        byVariant[variantGroupName] = [NSMutableArray array];
                    }
                    [byVariant[variantGroupName] addObject:[GCTag tagNamed:variant[kName]]];
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
        NSString *tagName = [NSString stringWithFormat:@"custom%@%@", code, [type capitalizedString]];
        if ([_tagStore valueForKey:tagName]) {
            return [_tagStore valueForKey:tagName];
        }
        GCTag *tag = [[GCTag alloc] initWithName:tagName
                                        settings:@{kCode: code,
                                                  kName: tagName,
                                                  kPlural: [NSString stringWithFormat:@"%@s", tagName],
                                                  kValueType: @"string",
                                                  kObjectType: type,
                                                  kValidSubTags: [NSArray array]}];
        NSLog(@"Created %@: %@", tagName, tag);
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
        
        _cachedOccurencesDicts = [occurrencesDicts copy];
    }
    
    NSDictionary *validDict = _cachedOccurencesDicts[tag.name];
    
    NSParameterAssert(validDict);
    
    NSInteger min = [validDict[kMin] integerValue];
    
    NSInteger max = [validDict[kMax] isEqual:@"M"]
                  ? NSIntegerMax
                  : [validDict[kMax] integerValue]
                  ;
	
    return (GCAllowedOccurrences){min, max};
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
        
        //NSLog(@"valueTypeString: %@ => %@", valueTypeString, _cachedValueClass);
    }
    
	return _cachedValueClass;
}

- (Class)objectClass
{
    if (!_cachedObjectClass) {
        NSString *lookupName = self.name;
        if (self.isCustom) {
            lookupName = @"custom";
        }
        NSString *objectClassString = [NSString stringWithFormat:@"GC%@%@%@", [[lookupName substringToIndex:1] uppercaseString], [lookupName substringFromIndex:1], [_settings[kObjectType] capitalizedString]];
        
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

static inline void expandSubtag(NSMutableOrderedSet *set, NSDictionary *valid) {
    if (valid[kGroupName]) {
        for (NSDictionary *variant in _tagInfo[valid[kGroupName]][kVariants]) {
            expandSubtag(set, variant);
        }
    } else {
        [set addObject:[GCTag tagNamed:[valid[kMax] isEqual:@"M"] ? _singularToPlural[valid[kName]] : valid[kName]]];
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
