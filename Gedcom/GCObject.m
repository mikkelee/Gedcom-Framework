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

@interface GCObject ()

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key; //searches internally for key, for example "Birth"
- (void)setNilValueForKey:(NSString *)key; //deletes internal record
- (void)setValue:(id)value forUndefinedKey:(NSString *)key; //creates internal record

@end

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

+ (id)objectWithGedcomNode:(GCNode *)node
{
    GCObject *object = [[GCObject alloc] initWithType:[[node gedTag] name]];
    
    //TODO xref?
    
    [object setStringValue:[node gedValue]];
    
    for (id subNode in [node subNodes]) {
        [object addRecord:[GCObject objectWithGedcomNode:subNode]];
    }
    
    return object;
}

- (void)addRecord:(GCObject *)object
{
    id key = [object type];
    id existing = [self valueForKey:key];
    
    BOOL allowsMultiple = true; //TODO
    
    if (allowsMultiple && existing) {
        //one exists already, so we get in array mode:
        
        if ([existing isKindOfClass:[NSMutableArray class]]) {
            //already have an array, so just add here:
            [existing addObject:object];
        } else {
            //create array and put both in:
            NSMutableArray *objects = [NSMutableArray arrayWithObjects:existing, object, nil];
            [self setValue:objects forKey:key];
        }
    } else {
        [self setValue:object forKey:key];
    }
}

- (GCNode *)gedcomNode
{
    GCTag *tag = [GCTag tagNamed:_type];
    
    NSString *xref = nil; //TODO have some xref generator?
    
    NSMutableArray *subNodes = [NSMutableArray arrayWithCapacity:3];
    
    for (id subTag in [tag validSubTags]) {
        for (id tagAlias in [GCTag aliasesForTag:subTag]) {
            id obj = [_records objectForKey:[GCTag nameForTag:tagAlias]];
            
            if (obj) {
                if ([obj isKindOfClass:[NSMutableArray class]]) {
                    NSArray *sorted = [obj sortedArrayUsingComparator:^(id obj1, id obj2) {
                        return [[obj1 stringValue] compare:[obj2 stringValue]];
                    }];
                    for (id subObj in sorted) {
                        [subNodes addObject:[subObj gedcomNode]];
                    }
                } else {
                    [subNodes addObject:[obj gedcomNode]];
                }
            }
        }
    }
    
    GCNode *node = [[GCNode alloc] initWithTag:tag value:[self stringValue] xref:xref subNodes:subNodes];
    
    return node;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (type: %@, stringValue: %@)", [super description], [self type], [self stringValue]];
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_records objectForKey:key];
}

- (void)setNilValueForKey:(NSString *)key
{
    [_records removeObjectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //TODO validity check (don't put a NAME on a FAM, etc)
    
    [_records setObject:value forKey:key];
}

@synthesize type = _type;

//TODO handle multiple value types (dates, numbers, strings, ages; acc. to tags.plist?)
@synthesize stringValue;

@end
