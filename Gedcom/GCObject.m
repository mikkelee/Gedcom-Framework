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
    //TODO handle multiple records of same type (NAMEs etc)
    [self setValue:object forKey:[object type]];
}

- (GCNode *)gedcomNode
{
    GCTag *tag = [GCTag tagNamed:_type];
    
    NSString *xref = nil; //TODO have some xref generator?
    
    //TODO handle multiple records of same type (NAMEs etc)
    //TODO enforce correct tag order
    NSMutableArray *subNodes = [NSMutableArray arrayWithCapacity:3];
    for (id key in _records) {
        [subNodes addObject:[[_records objectForKey:key] gedcomNode]];
    }
    
    GCNode *node = [[GCNode alloc] initWithTag:tag value:[self stringValue] xref:xref subNodes:subNodes];
    
    return node;
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key
{
    //search internally for key, for example "Birth" - can return mutable arrays etc
    id value = [_records objectForKey:key];
    
    if (value == nil) {
        value = [super valueForUndefinedKey:key];
    }
    
    return value;
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
