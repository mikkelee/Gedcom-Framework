//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"
#import "GCGedcomController.h"

@interface GCTag ()

@end

@implementation GCTag {
    NSString *_code;
}

__strong static NSMutableDictionary *tags;
__strong static NSMutableDictionary *codeLookup;

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
    if (codeLookup == nil) {
        codeLookup = [NSMutableDictionary dictionaryWithCapacity:10];
        
        for (id key in [[[GCGedcomController sharedController] tags] valueForKey:@"tagNames"]) {
            [codeLookup setObject:key 
                           forKey:[[[[GCGedcomController sharedController] tags] valueForKey:@"tagNames"] 
                                   objectForKey:key]];
        }
    }
    
    NSString *code = [codeLookup objectForKey:name];
    
    return [GCTag tagCoded:code];
}

-(NSArray *)validSubTags
{
    //TODO also for @aliases etc
    return [[[[GCGedcomController sharedController] tags] objectForKey:@"validSubTags"] objectForKey:_code];
}

-(BOOL)isValidSubTag:(GCTag *)tag
{
    return [[self validSubTags] containsObject:[tag code]];
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
    return [[[[GCGedcomController sharedController] tags] valueForKey:@"tagNames"] valueForKey:_code];
}

- (BOOL)isCustom
{
    return ([self name] == nil);
}

@end
