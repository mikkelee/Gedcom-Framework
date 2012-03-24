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

const NSString *kTagNames = @"tagNames";

+ (void)setupTagInfo
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        NSString *plistPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"tags" ofType:@"plist"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSMutableDictionary *_tags = [[NSPropertyListSerialization propertyListFromData:data 
                                                                       mutabilityOption:0 
                                                                                 format:NULL 
                                                                       errorDescription:nil] mutableCopy];
        
        //adding reverse lookups:
        NSMutableDictionary *nameTags = [NSMutableDictionary dictionaryWithCapacity:10];
        for (id tag in [_tags objectForKey:kTagNames]) {
            [nameTags setObject:tag forKey:[[_tags objectForKey:kTagNames] objectForKey:tag]];
        }
        [_tags setObject:nameTags forKey:@"nameTags"];
        
        NSMutableDictionary *reverseAliases = [NSMutableDictionary dictionaryWithCapacity:10];
        for (id tag in [_tags objectForKey:@"tagAliases"]) {
            for (id alias in [[_tags objectForKey:@"tagAliases"] objectForKey:tag]) {
                [reverseAliases setObject:tag forKey:alias];
            }
        }
        [_tags setObject:reverseAliases forKey:@"reverseAliases"];
        
        tagInfo = [_tags copy];
        //NSLog(@"tagInfo: %@", [tagInfo]);
    });
}

+ (NSString *)nameForTag:(NSString *)tag
{
    return [[tagInfo objectForKey:kTagNames] objectForKey:tag];
}

+ (NSString *)tagForName:(NSString *)name
{
    return [[tagInfo objectForKey:@"nameTags"] objectForKey:name];
}

+ (NSArray *)aliasesForTag:(NSString *)tag
{
    NSArray *aliases = [[tagInfo objectForKey:@"tagAliases"] objectForKey:tag];
    
    if (aliases == nil || [aliases count] == 0) {
        aliases = [NSArray arrayWithObject:tag];
    }
    
    return aliases;
}

+ (NSString *)tagForAlias:(NSString *)alias
{
    NSString *tag = [[tagInfo objectForKey:@"reverseAliases"] objectForKey:alias];
    
    if (tag == nil) {
        tag = alias;
    }
    
    return tag;
}

+ (NSArray *)validSubTagsForTag:(NSString *)tag
{
    return [[tagInfo objectForKey:@"validSubTags"] objectForKey:tag];
}

-(id)initWithCode:(NSString *)code
{
    self = [super init];
    
    if (self) {
        _code = code;
    }
    
    return self;    
}

+(GCTag *)tagCoded:(NSString *)code
{
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
    return [GCTag tagCoded:[[self class] tagForName:name]];
}

-(NSArray *)validSubTags
{
    NSArray *valid = [NSArray array];
    
    valid = [valid arrayByAddingObjectsFromArray:[[self class] validSubTagsForTag:_code]];
    valid = [valid arrayByAddingObjectsFromArray:[[self class] validSubTagsForTag:[[self class] tagForAlias:_code]]];
    
    return valid;
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
    return [[tagInfo valueForKey:@"tagNames"] valueForKey:_code];
}

- (BOOL)isCustom
{
    return ([self name] == nil);
}

@end
