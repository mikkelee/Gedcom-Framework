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
        tag = [[GCTag alloc] initWithCode:code];
        [tags setObject:tag forKey:code];
    }
    
    return tag;
}

+(GCTag *)tagNamed:(NSString *)name
{
    return nil; //TODO
}

-(NSArray *)validSubTags
{
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
