//
//  GedcomController.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGedcomController.h"

@interface GCGedcomController ()

@property NSDictionary *tags; 

@end

@implementation GCGedcomController

//TODO add more consts:
const NSString *kTagNames = @"tagNames";

+ (id)sharedController // fancy new ARC/GCD singleton!
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
        
        if (_sharedInstance) {
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
            
            [_sharedInstance setTags:[_tags copy]];
            //NSLog(@"tags: %@", [_sharedInstance tags]);
        }
    });
    
    return _sharedInstance;
}

+ (NSString *)nameForTag:(NSString *)tag
{
    return [[[[self sharedController] tags] objectForKey:kTagNames] objectForKey:tag];
}

+ (NSString *)tagForName:(NSString *)name
{
    return [[[[self sharedController] tags] objectForKey:@"nameTags"] objectForKey:name];
}

+ (NSArray *)aliasesForTag:(NSString *)tag
{
    NSArray *aliases = [[[[self sharedController] tags] objectForKey:@"tagAliases"] objectForKey:tag];
    
    if (aliases == nil || [aliases count] == 0) {
        aliases = [NSArray arrayWithObject:tag];
    }
    
    return aliases;
}

+ (NSString *)tagForAlias:(NSString *)alias
{
    NSString *tag = [[[[self sharedController] tags] objectForKey:@"reverseAliases"] objectForKey:alias];
    
    if (tag == nil) {
        tag = alias;
    }
    
    return tag;
}

+ (NSArray *)validSubTagsForTag:(NSString *)tag
{
    return [[[[self sharedController] tags] objectForKey:@"validSubTags"] objectForKey:tag];
}

@synthesize tags;

@end
