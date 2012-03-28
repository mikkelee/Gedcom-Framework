//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"

@interface GCTag ()

-(id)initWithCode:(NSString *)code 
			 name:(NSString *)name 
		valueType:(GCValueType)valueType 
	  objectClass:(Class)objectClass
	 validSubTags:(NSOrderedSet *)validSubTags;

@end

@implementation GCTag {
    NSString *_code;
    NSString *_name;
    NSOrderedSet *_validSubTags;
    GCValueType _valueType;
	Class _objectType;
}

#pragma mark Constants

const NSString *kTags = @"tags";
const NSString *kNameTags = @"nameTags";
const NSString *kValidSubTags = @"validSubTags";
const NSString *kRootTags = @"rootTags";
const NSString *kAliases = @"aliases";

#pragma mark Setup

__strong static NSMutableDictionary *tags;
__strong static NSDictionary *tagInfo;

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
        
        NSAssert(err == nil, @"error: %@", err);
        
        //setup aliases:
        NSMutableDictionary *aliases = [NSMutableDictionary dictionaryWithCapacity:3];
        for (NSString *c in [_tags objectForKey:kTags]) {
            NSString *code = c;
            
            NSDictionary *tagDict = [[_tags objectForKey:kTags] objectForKey:code];
            
            if ([tagDict objectForKey:@"code"]) {
                code = [tagDict objectForKey:@"code"];
            }
            
            for (id alias in [tagDict objectForKey:kAliases]) {
                [aliases setObject:code forKey:alias];
            }
        }
        
        NSLog(@"aliases: %@", aliases);
        
        tags = [NSMutableDictionary dictionaryWithCapacity:10];
        
        NSMutableDictionary *nameTags = [NSMutableDictionary dictionaryWithCapacity:10];
        for (NSString *c in [_tags objectForKey:kTags]) {
            NSString *code = c;
            
            NSDictionary *tagDict = [[_tags objectForKey:kTags] objectForKey:code];
            
            //override code (for instance, source records and source references are both SOUR)
            if ([tagDict objectForKey:@"code"]) {
                code = [tagDict objectForKey:@"code"];
            }
            
            NSString *name = [tagDict objectForKey:@"name"];
            
            NSString *valueTypeString = [tagDict objectForKey:@"valueType"];
            
            if (valueTypeString == nil || [valueTypeString isEqualToString:@""]) {
                valueTypeString = [[[_tags objectForKey:kTags] objectForKey:[aliases objectForKey:code]] objectForKey:@"valueType"];
            }
            
            NSString *objectClassString = [tagDict objectForKey:@"objectClass"];
            
            if (objectClassString == nil || [objectClassString isEqualToString:@""]) {
                objectClassString = [[[_tags objectForKey:kTags] objectForKey:[aliases objectForKey:code]] objectForKey:@"objectClass"];
            }
            
            NSMutableOrderedSet *validSubTags = [NSMutableOrderedSet orderedSetWithCapacity:3];
            
            //validSubTags from self:
            for (id subTag in [tagDict objectForKey:kValidSubTags]) {
                if ([subTag hasPrefix:@"@"]) {
                    NSLog(@"subTag: %@", subTag);
                    NSDictionary *aliasDict = [[_tags objectForKey:kTags] objectForKey:subTag];
                    for (id alias in [aliasDict objectForKey:kAliases]) {
                        [validSubTags addObject:alias];
                    }
                    for (id aliasSubTag in [aliasDict objectForKey:kValidSubTags]) {
                        [validSubTags addObject:aliasSubTag];
                    }
                } else {
                    [validSubTags addObject:subTag];
                }
            }
            
            //validSubTags from alias:
            for (id subTag in [[[_tags objectForKey:kTags] objectForKey:[aliases objectForKey:code]] objectForKey:kValidSubTags]) {
                if ([subTag hasPrefix:@"@"]) {
                    NSLog(@"subTag: %@", subTag);
                    NSDictionary *aliasDict = [[_tags objectForKey:kTags] objectForKey:subTag];
                    for (id alias in [aliasDict objectForKey:kAliases]) {
                        [validSubTags addObject:alias];
                    }
                    for (id aliasSubTag in [aliasDict objectForKey:kValidSubTags]) {
                        [validSubTags addObject:aliasSubTag];
                    }
                } else {
                    [validSubTags addObject:subTag];
                }
            }
            
            GCTag *tag = [[GCTag alloc] initWithCode:code 
                                                name:name
                                           valueType:[GCValue valueTypeNamed:valueTypeString]
										 objectClass:NSClassFromString(objectClassString)
                                        validSubTags:validSubTags];
            
            [tags setObject:tag forKey:code];
            
            NSAssert([nameTags objectForKey:[tagDict objectForKey:@"name"]] == nil, @"Duplicate name: %@ for codes: %@, %@", [tagDict objectForKey:@"name"], code, [nameTags objectForKey:[tagDict objectForKey:@"name"]]);
            [nameTags setObject:code forKey:[tagDict objectForKey:@"name"]];
        }
        [_tags setObject:nameTags forKey:kNameTags];
        [_tags setObject:[[[_tags objectForKey:kTags] objectForKey:@"@reco"] objectForKey:@"aliases"] forKey:kRootTags];
        
        tagInfo = [_tags copy];
        NSLog(@"tagInfo: %@", tagInfo);
    });
}

+ (NSString *)codeForName:(NSString *)name
{
    return [[tagInfo objectForKey:kNameTags] objectForKey:name];
}

#pragma mark Initialization

-(id)initWithCode:(NSString *)code 
			 name:(NSString *)name 
		valueType:(GCValueType)valueType 
	  objectClass:(Class)objectClass
	 validSubTags:(NSOrderedSet *)validSubTags
{
    NSParameterAssert(code != nil);
    
    self = [super init];
    
    if (self) {
        _code = code;
        _name = name;
        _valueType = valueType;
        _objectClass = objectClass;
        _validSubTags = validSubTags;
    }
    
    return self;    
}

#pragma mark Convenience constructors

+(GCTag *)tagCoded:(NSString *)code
{
    NSParameterAssert(code != nil);
    
    [self setupTagInfo];
    
    GCTag *tag = [tags objectForKey:code];
    
    if (tag == nil) {
        tag = [[self alloc] initWithCode:code
                                    name:[NSString stringWithFormat:@"Custom %@ tag", code]
                               valueType:GCStringValue
							 objectClass:NSClassFromString(@"GCAttribute")
                            validSubTags:[NSOrderedSet orderedSet]];
        [tags setObject:tag forKey:code];
    }
    
    return tag;
}

+(GCTag *)tagNamed:(NSString *)name
{
    NSParameterAssert(name != nil);
    
    return [GCTag tagCoded:[[self class] codeForName:name]];
}

#pragma mark Subtags

-(BOOL)isValidSubTag:(GCTag *)tag
{
    return [tag isCustom] || [[self validSubTags] containsObject:[tag code]];
}

#pragma mark Description

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
	return [GCTag tagCoded:[decoder decodeObjectForKey:@"gedTag"]];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self; //safe, since GCTags are immutable
}

#pragma mark Properties

@synthesize code = _code;
@synthesize name = _name;
@synthesize valueType = _valueType;
@synthesize objectClass = _objectClass;
@synthesize validSubTags = _validSubTags;

- (BOOL)isCustom
{
    return ([[self name] isEqualToString:[NSString stringWithFormat:@"Custom %@ tag", _code]]);
}

- (BOOL)isRoot
{
    return [[tagInfo objectForKey:kRootTags] containsObject:[self code]];
}

@end
