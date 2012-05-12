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

#pragma mark Setup

__strong static NSMutableDictionary *tagStore;
__strong static NSMutableDictionary *tagInfo;

+ (void)recurse:(NSString *)key
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
            [self recurse:variantName];
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
            [self recurse:[subTag objectForKey:kName]];
        }
    }
}

+ (void)setupTagInfo
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        
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
        [self recurse:@"@rootObject"];
        
        //TODO get rid of this when tags.json is finalized:
        for (NSString *key in [tagInfo keyEnumerator]) {
            if (![tagStore objectForKey:key]) {
                NSMutableDictionary *tagDict = [tagInfo objectForKey:key];
                if (![tagDict objectForKey:kCode]) {
                    continue;
                }
                GCTag *tag = [[GCTag alloc] initWithName:key
                                                settings:tagDict];
                
                NSParameterAssert([tagStore objectForKey:key] == nil);
                [tagStore setObject:tag 
                             forKey:key];
            }
        }
    });
}

+ (NSDictionary *)tagsByName
{
    return [tagStore copy];
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
                         @"header", @"HEAD",
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

- (GCTag *)subTagWithCode:(NSString *)code
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
                                                  @"attribute", kObjectType,
                                                  [NSOrderedSet orderedSet], kValidSubTags,
                                                  nil]];
        NSLog(@"Created custom %@ tag: %@", code, tag);
        [tagStore setObject:tag forKey:tagName];
        
        return tag;
    }
    
    for (GCTag *subTag in [self validSubTags]) {
        if ([[subTag code] isEqualToString:code]) {
            return subTag;
        }
    }
    
    return nil;
}

- (GCTag *)subTagWithName:(NSString *)name
{
    for (GCTag *subTag in [self validSubTags]) {
        if ([[subTag name] isEqualToString:name]) {
            return subTag;
        }
    }
    
    return nil;
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
    
    //TODO cache this:
    
    if ([_settings objectForKey:kValidSubTags] == nil) {
        return (GCAllowedOccurrences){0, 0};
    }
    
    NSDictionary *validDict = nil;
    for (NSDictionary *valid in [_settings objectForKey:kValidSubTags]) {
        if ([[valid objectForKey:kName] hasPrefix:@"@"]) {
            for (NSString *variantName in [[tagInfo objectForKey:[valid objectForKey:kName]] objectForKey:kVariants]) {
                if ([variantName isEqual:[tag name]]) {
                    validDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 variantName, kName, 
                                 [valid objectForKey:@"min"], @"min",
                                 [valid objectForKey:@"max"], @"max",
                                 nil];
                    break;
                }
            }
        } else {
            if ([[valid objectForKey:kName] isEqual:[tag name]]) {
                validDict = valid;
                break;
            }
        }
    }
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

- (NSString *)code
{
    return [_settings objectForKey:kCode];
}

- (Class)valueType
{
	NSString *valueTypeString = [_settings objectForKey:kValueType];
    
    Class valueClass = NSClassFromString([NSString stringWithFormat:@"GC%@", [valueTypeString capitalizedString]]);
    
	return valueClass;
}

- (Class)objectClass
{
	NSString *objectClassString = [_settings objectForKey:kObjectType];
    
	Class objectClass = NSClassFromString([NSString stringWithFormat:@"GC%@", [objectClassString capitalizedString]]);
		
	return objectClass;
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
