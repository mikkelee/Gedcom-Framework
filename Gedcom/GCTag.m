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
		 settings:(NSDictionary *)settings;

@end

@implementation GCTag {
    NSString *_code;
    NSString *_name;
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
            
            if ([tagDict objectForKey:kCode]) {
                code = [tagDict objectForKey:kCode];
            }
            
            for (id alias in [tagDict objectForKey:kAliases]) {
                [aliases setObject:code forKey:alias];
            }
        }
        
        //NSLog(@"aliases: %@", aliases);
        
        tags = [NSMutableDictionary dictionaryWithCapacity:10];
        
        NSMutableDictionary *nameTags = [NSMutableDictionary dictionaryWithCapacity:10];
        for (NSString *c in [_tags objectForKey:kTags]) {
            NSString *code = c;
            
            NSMutableDictionary *settings = [[[_tags objectForKey:kTags] objectForKey:code] mutableCopy];
            
            //override code (for instance, source records and source references are both SOUR)
            if ([settings objectForKey:kCode]) {
                code = [settings objectForKey:kCode];
            }
            
            NSString *name = [settings objectForKey:@"name"];
            
            NSString *valueTypeString = [settings objectForKey:@"valueType"];
            if (valueTypeString == nil || [valueTypeString isEqualToString:@""]) {
                valueTypeString = [[[_tags objectForKey:kTags] objectForKey:[aliases objectForKey:code]] objectForKey:@"valueType"];
				if (valueTypeString != nil) {
					[settings setObject:valueTypeString forKey:@"valueType"];
				}
            }
			
            NSString *objectClassString = [settings objectForKey:@"objectClass"];
            if (objectClassString == nil || [objectClassString isEqualToString:@""]) {
                objectClassString = [[[_tags objectForKey:kTags] objectForKey:[aliases objectForKey:code]] objectForKey:@"objectClass"];
				if (objectClassString != nil) {
					[settings setObject:objectClassString forKey:@"objectClass"];
				}
            }
            
            NSMutableOrderedSet *validSubTags = [NSMutableOrderedSet orderedSetWithCapacity:3];
            
            //validSubTags from self:
            for (id subTag in [settings objectForKey:kValidSubTags]) {
                if ([subTag hasPrefix:@"@"]) {
                    //NSLog(@"subTag: %@", subTag);
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
                    //NSLog(@"subTag: %@", subTag);
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
			
			[settings setObject:validSubTags forKey:kValidSubTags];
            
            [tags setObject:[[GCTag alloc] initWithCode:code
												   name:name
											   settings:settings] 
					 forKey:code];
            
            NSAssert([nameTags objectForKey:[settings objectForKey:@"name"]] == nil, @"Duplicate name: %@ for codes: %@, %@", [settings objectForKey:@"name"], code, [nameTags objectForKey:[settings objectForKey:@"name"]]);
            [nameTags setObject:code forKey:[settings objectForKey:@"name"]];
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
		 settings:(NSDictionary *)settings
{
    NSParameterAssert(code != nil);
    
    self = [super init];
    
    if (self) {
        _code = code;
        _name = name;
        _settings = settings;
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
								settings:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"GCStringValue", @"valueType",
										  @"GCAttribute", @"objectClass",
										  [NSOrderedSet orderedSet], @"validSubTags",
										  nil]];
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

- (GCValueType)valueType
{
	NSString *valueTypeString = [_settings objectForKey:@"valueType"];
	GCValueType valueType = [GCValue valueTypeNamed:valueTypeString];
	
	if (valueType == GCUndefinedValue) {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidValueTypeException"
														 reason:[NSString stringWithFormat:@"Invalid <valueType> '%@' in %@", valueTypeString, _settings]
													   userInfo:_settings];
		@throw exception;
	}
	
	return valueType;
}

- (Class)objectClass
{
	NSString *objectClassString = [_settings objectForKey:@"objectClass"];
	Class objectClass = NSClassFromString(objectClassString);
	
	if (objectClass == nil) {
		NSException *exception = [NSException exceptionWithName:@"GCInvalidObjectClassException"
														 reason:[NSString stringWithFormat:@"Invalid <objectClass> '%@' in %@", objectClassString, _settings]
													   userInfo:_settings];
		@throw exception;
	}
	
	return objectClass;
}

- (NSOrderedSet *)validSubTags
{
	return [_settings objectForKey:kValidSubTags];
}

- (GCTag *)reverseRelationshipTag
{
	NSString *code = [_settings objectForKey:kReverseRelationshipTag];
	
	if (code != nil) {
		return [GCTag tagCoded:code];
	} else {
		return nil;
	}
}

- (BOOL)isCustom
{
    return ([[self name] isEqualToString:[NSString stringWithFormat:@"Custom %@ tag", _code]]);
}

- (BOOL)isRoot
{
    return [[tagInfo objectForKey:kRootTags] containsObject:[self code]];
}

@end
