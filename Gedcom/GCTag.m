//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"

@interface GCTag ()

@end

@implementation GCTag {
    NSString *_code;
}

__strong static NSMutableDictionary *tags;
__strong static NSDictionary *tagInfo;

//dict keys
const NSString *kTags = @"tags";
const NSString *kNameTags = @"nameTags";
const NSString *kTagAliases = @"tagAliases";
const NSString *kValidSubTags = @"validSubTags";
const NSString *kReverseAliases = @"reverseAliases";

+ (void)setupTagInfo
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        NSString *plistPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"tags" ofType:@"plist"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        
        NSString *err = nil;
        
        NSMutableDictionary *_tags = [[NSPropertyListSerialization propertyListFromData:data 
                                                                       mutabilityOption:0 
                                                                                 format:NULL 
                                                                       errorDescription:&err] mutableCopy];
        
        if (err) {
            NSLog(@"error: %@", err);
            
        }
        
        //adding reverse lookups:
        NSMutableDictionary *nameTags = [NSMutableDictionary dictionaryWithCapacity:10];
        for (id tag in [_tags objectForKey:kTags]) {
            [nameTags setObject:tag forKey:[[[_tags objectForKey:kTags] objectForKey:tag] objectForKey:@"name"]];
        }
        [_tags setObject:nameTags forKey:kNameTags];
        
        NSMutableDictionary *reverseAliases = [NSMutableDictionary dictionaryWithCapacity:10];
        for (id tag in [_tags objectForKey:kTagAliases]) {
            for (id alias in [[_tags objectForKey:kTagAliases] objectForKey:tag]) {
                [reverseAliases setObject:tag forKey:alias];
            }
        }
        [_tags setObject:reverseAliases forKey:kReverseAliases];
        
        tagInfo = [_tags copy];
        //NSLog(@"tagInfo: %@", tagInfo);
    });
}

+ (NSString *)nameForTag:(NSString *)tag
{
    return [[[tagInfo objectForKey:kTags] objectForKey:tag] objectForKey:@"name"];
}

+ (NSString *)tagForName:(NSString *)name
{
    return [[tagInfo objectForKey:kNameTags] objectForKey:name];
}

+ (NSArray *)aliasesForTag:(NSString *)tag
{
    NSArray *aliases = [[tagInfo objectForKey:kTagAliases] objectForKey:tag];
    
    if (aliases == nil || [aliases count] == 0) {
        aliases = [NSArray arrayWithObject:tag];
    }
    
    return aliases;
}

+ (NSString *)tagForAlias:(NSString *)alias
{
    NSString *tag = [[tagInfo objectForKey:kReverseAliases] objectForKey:alias];
    
    if (tag == nil) {
        tag = alias;
    }
    
    return tag;
}

+ (NSArray *)validSubTagsForTag:(NSString *)tag
{
    return [[[tagInfo objectForKey:kTags] objectForKey:tag] objectForKey:kValidSubTags];
}

-(id)initWithCode:(NSString *)code
{
    NSParameterAssert(code != nil);
    
    self = [super init];
    
    if (self) {
        _code = code;
    }
    
    return self;    
}

+(GCTag *)tagCoded:(NSString *)code
{
    NSParameterAssert(code != nil);
    
    [self setupTagInfo];
    
    if (tags == nil) {
        tags = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    GCTag *tag = [tags objectForKey:code];
    
    if (tag == nil) {
        tag = [[self alloc] initWithCode:code];
        [tags setObject:tag forKey:code];
    }
    
    return tag;
}

+(GCTag *)tagNamed:(NSString *)name
{
    NSParameterAssert(name != nil);
    
    return [GCTag tagCoded:[[self class] tagForName:name]];
}

-(NSOrderedSet *)validSubTags
{
    NSMutableOrderedSet *validTags = [NSMutableOrderedSet orderedSetWithCapacity:3];
    
    NSMutableArray *tags = [NSMutableArray arrayWithCapacity:3];
    [tags addObjectsFromArray:[[self class] validSubTagsForTag:_code]];
    [tags addObjectsFromArray:[[self class] validSubTagsForTag:[[self class] tagForAlias:_code]]];
    
    for (id tag in tags) {
        [validTags addObject:tag];
        [validTags addObjectsFromArray:[[self class] aliasesForTag:tag]];
    }
    
    return validTags;
}

-(BOOL)isValidSubTag:(GCTag *)tag
{
    return [[self validSubTags] containsObject:[tag code]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", [super description], [self code]];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder setValue:_code forKey:@"gedTag"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
    
    if (self) {
        _code = [decoder decodeObjectForKey:@"gedTag"];
	}
    
    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark Properties

- (NSString *)code
{
    return _code;
}

- (NSString *)name
{
    return [[[tagInfo objectForKey:kTags] objectForKey:_code] objectForKey:@"name"];
}

-(GCValueType)valueType
{
    NSString *valueType = [[[tagInfo objectForKey:kTags] objectForKey:_code] objectForKey:@"valueType"];
    
    if (valueType == nil) {
        valueType = [[[tagInfo objectForKey:kTags] objectForKey:[[self class] tagForAlias:_code]] objectForKey:@"valueType"];
    }
    
    return [GCValue valueTypeNamed:valueType];
}

- (BOOL)isCustom
{
    return ([self name] == nil);
}

@end
