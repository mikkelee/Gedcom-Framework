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
    NSString *_tag;
}

__strong static NSMutableDictionary *tags;

-(id)initWithTag:(NSString *)tag
{
    self = [super init];
    
    if (self) {
        _tag = tag;
    }
    
    return self;    
}

+(GCTag *)tagAbbreviated:(NSString *)t
{
    if (tags == nil) {
        tags = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    GCTag *tag = [tags valueForKey:t];
    
    if (tag == nil) {
        tag = [[GCTag alloc] initWithTag:t];
        [tags setObject:tag forKey:t];
    }
    
    return tag;
}

+(GCTag *)tagNamed:(NSString *)name
{
    return nil; //TODO
}

-(NSArray *)validSubTags
{
    return nil; //TODO
}

-(BOOL)isValidSubTag:(GCTag *)tag
{
    return NO; //TODO
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder setValue:_tag forKey:@"gedTag"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
    
    if (self) {
        _tag = [decoder decodeObjectForKey:@"gedTag"];
	}
    
    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark Properties

- (NSString *)tag
{
    return _tag;
}

- (NSString *)name
{
    return [[[[GCGedcomController sharedController] tags] valueForKey:@"tagNames"] valueForKey:_tag];
}

- (BOOL)isCustom
{
    return ([self name] == nil);
}

@end
