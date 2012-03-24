//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

@implementation GCObject {
    NSString *_type;
    NSMutableDictionary *_records;
}

- (id)initWithType:(NSString *)type
{
    self = [super init];
    
    if (self) {
        _type = type;
        _records = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    return self;    
}

+ (id)objectWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

- (void)addRecord:(GCObject *)object
{
    id existing = [self valueForKey:[object type]];
    
    if (existing) {
        //one exists already, so we get in array mode:
        //TODO check if multiple are allowed
        
        if ([existing isKindOfClass:[NSMutableArray class]]) {
            //already have an array, so just add here:
            [existing addObject:object];
        } else {
            //create array and put both in:
            NSMutableArray *objects = [NSMutableArray arrayWithObjects:existing, object, nil];
            [self setValue:objects forKey:[object type]];
        }
        
    } else {
        [self setValue:object forKey:[object type]];
    }
}

- (GCNode *)gedcomNode
{
    GCTag *tag = [GCTag tagNamed:_type];
    
    NSString *xref = nil; //TODO have some xref generator?
    
    //TODO handle multiple records of same type (NAMEs etc)
    //TODO enforce correct tag order
    NSMutableArray *subNodes = [NSMutableArray arrayWithCapacity:3];
    [_records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if ([obj isKindOfClass:[NSMutableArray class]]) {
            for (id object in obj) {
                [subNodes addObject:[object gedcomNode]];
            }
        } else {
            [subNodes addObject:[obj gedcomNode]];
        }
    }];
    
    GCNode *node = [[GCNode alloc] initWithTag:tag value:[self stringValue] xref:xref subNodes:subNodes];
    
    return node;
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key
{
    //search internally for key, for example "Birth" - may return mutable arrays etc
    return [_records objectForKey:key];
}

- (void)setNilValueForKey:(NSString *)key
{
    //delete internal record
    [_records removeObjectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //create internal record
    
    //TODO validity check (don't put a NAME on a FAM, etc)
    
    [_records setObject:value forKey:key];
}

@synthesize type = _type;

//TODO handle multiple value types (dates, numbers, strings, ages; acc. to tags.plist?)
@synthesize stringValue;

@end
