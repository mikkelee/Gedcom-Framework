//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"

@interface GCTag ()

-(id)initWithName:(NSString *)name 
		 settings:(NSDictionary *)settings;

@end

@implementation GCTag {
	NSDictionary *_settings;
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
        
        tagStore = [NSMutableDictionary dictionaryWithCapacity:10];
        [self recurse:@"@Root object"];
        
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
                
                NSString *typeCodeKey = [NSString stringWithFormat:@"%@:%@", [tagDict objectForKey:kObjectType], [tagDict objectForKey:kCode]];
                NSParameterAssert([tagStore objectForKey:typeCodeKey] == nil);
                [tagStore setObject:tag
                             forKey:typeCodeKey];
            }
        }
    });
}

#pragma mark Initialization

-(id)initWithName:(NSString *)name 
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

#pragma mark Convenience constructors

+(GCTag *)tagWithType:(NSString *)type code:(NSString *)code
{
    NSParameterAssert(type != nil);
    NSParameterAssert(code != nil);
    
    [self setupTagInfo];
    
    GCTag *tag = [tagStore objectForKey:[NSString stringWithFormat:@"%@:%@", type, code]];
    
    if (tag == nil) {
        tag = [[self alloc] initWithName:[NSString stringWithFormat:@"Custom %@ tag", code]
								settings:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"GCStringValue", kValueType,
										  @"GCAttribute", kObjectType,
										  [NSOrderedSet orderedSet], kValidSubTags,
										  nil]];
        NSLog(@"Created custom %@ %@ tag: %@", type, code, tag);
        [tagStore setObject:tag forKey:code];
    }
    
    return tag;
}

+(GCTag *)tagNamed:(NSString *)name
{
    NSParameterAssert(name != nil);
    
    GCTag *tag = [tagStore objectForKey:name];
    
    if (tag == nil) {
        tag = [[self alloc] initWithName:name //TODO "Custom"?
								settings:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"GCStringValue", kValueType,
										  @"GCAttribute", kObjectType,
										  [NSOrderedSet orderedSet], kValidSubTags,
										  nil]];
        NSLog(@"Created custom %@ tag: %@", name, tag);
        [tagStore setObject:tag forKey:name];
    }
    
    return tag;
}

#pragma mark Subtags

-(BOOL)isValidSubTag:(GCTag *)tag
{
    return [tag isCustom] || [[self validSubTags] containsObject:tag];
}

-(BOOL)allowsMultipleSubtags:(GCTag *)tag
{
    if ([tag isCustom]) {
        return YES;
    }
    
    //TODO cache this:
    
    if ([_settings objectForKey:kValidSubTags] == nil) {
        return NO;
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
                    continue;
                }
            }
        } else {
            if ([[valid objectForKey:kName] isEqual:[tag name]]) {
                validDict = valid;
                continue;
            }
        }
    }
    NSParameterAssert(validDict);
    
    //TODO use this:
	//NSInteger min = [[validDict objectForKey:@"min"] integerValue];
    
    NSInteger max = [[validDict objectForKey:@"max"] isEqual:@"M"]
                  ? INT_MAX
                  : [[validDict objectForKey:@"max"] integerValue]
                  ;
	
	return [tag isCustom] || max > 1;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@ %@)", [super description], [self code], [self name]];
}

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

#pragma mark Properties

@synthesize name = _name;

- (NSString *)code
{
    return [_settings objectForKey:kCode];
}

- (GCValueType)valueType
{
	NSString *valueTypeString = [_settings objectForKey:kValueType];
	GCValueType valueType = [GCValue valueTypeNamed:valueTypeString];
	
	if (valueType == GCUndefinedValue) {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidValueTypeException"
														 reason:[NSString stringWithFormat:@"Invalid <%@> '%@' in %@", kValueType, valueTypeString, _settings]
													   userInfo:_settings];
		@throw exception;
	}
	
	return valueType;
}

- (Class)objectClass
{
	NSString *objectClassString = [_settings objectForKey:kObjectType];
	Class objectClass = NSClassFromString(objectClassString);
	
	if (objectClass == nil) {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidObjectClassException"
														 reason:[NSString stringWithFormat:@"Invalid <%@> '%@' in %@", kObjectType, objectClassString, _settings]
													   userInfo:_settings];
		@throw exception;
	}
	
	return objectClass;
}

- (NSOrderedSet *)validSubTags
{
    //TODO cache this:
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
    
    return set;
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
