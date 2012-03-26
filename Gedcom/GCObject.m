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
#import "GCValue.h"

@implementation GCObject {
    GCTag *_tag;
    GCValue *_value;
    NSMutableDictionary *_records;
}

__strong static NSMutableDictionary *xrefStore;


+ (void)setupXrefStore
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        xrefStore = [NSMutableDictionary dictionaryWithCapacity:4];
    });
}

+ (void)storeXref:(NSString *)xref forObject:(GCObject *)obj
{
    [self setupXrefStore];
    [xrefStore setObject:xref forKey:[NSValue valueWithPointer:(const void *)obj]];
}

+ (NSString *)xrefForObject:(GCObject *)obj
{
    [self setupXrefStore];
    NSString *xref = [xrefStore objectForKey:[NSValue valueWithPointer:(const void *)obj]];
    
    if (xref == nil && [[GCTag tagForAlias:[GCTag tagForName:[obj type]]] isEqualToString:@"@reco"]) {
        xref = @"@I1@"; //TODO something like if (tag in @reco) {xref = special++}
        
        [self storeXref:xref forObject:obj];
    }
    
    return xref;
}

- (id)initWithType:(NSString *)type
{
    self = [super init];
    
    if (self) {
        _tag = [GCTag tagNamed:type];
        _records = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    return self;    
}

+ (id)objectWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

+ (id)objectWithType:(NSString *)type value:(GCValue *)value
{
    GCObject *new = [self objectWithType:type];
    
    [new setValue:value];
    
    return new;
}

+ (id)objectWithType:(NSString *)type stringValue:(NSString *)value
{
    return [self objectWithType:type 
                          value:[[GCValue alloc] initWithType:GCStringValue value:value]]; 
}

+ (id)objectWithType:(NSString *)type numberValue:(NSNumber *)value
{
    return [self objectWithType:type 
                          value:[[GCValue alloc] initWithType:GCNumberValue value:value]]; 
}

+ (id)objectWithType:(NSString *)type ageValue:(GCAge *)value
{
    return [self objectWithType:type 
                          value:[[GCValue alloc] initWithType:GCAgeValue value:value]]; 
}

+ (id)objectWithType:(NSString *)type dateValue:(GCDate *)value
{
    return [self objectWithType:type 
                          value:[[GCValue alloc] initWithType:GCDateValue value:value]]; 
}

- (void)addRecordWithType:(NSString *)type stringValue:(NSString *)value
{
    [self addRecord:[[self class] objectWithType:type stringValue:value]];
}

- (void)addRecordWithType:(NSString *)type numberValue:(NSNumber *)value
{
    [self addRecord:[[self class] objectWithType:type numberValue:value]];
}

- (void)addRecordWithType:(NSString *)type ageValue:(GCAge *)value
{
    [self addRecord:[[self class] objectWithType:type ageValue:value]];
}

- (void)addRecordWithType:(NSString *)type dateValue:(GCDate *)value
{
    [self addRecord:[[self class] objectWithType:type dateValue:value]];
}

+ (id)objectWithGedcomNode:(GCNode *)node
{
    GCObject *object = [[GCObject alloc] initWithType:[[node gedTag] name]];
    
    if ([node xref]) {
        [[self class] storeXref:[node xref] forObject:object];
    }
    
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
    NSMutableArray *subNodes = [NSMutableArray arrayWithCapacity:3];
    
    for (id subTag in [_tag validSubTags]) {
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
    
    GCNode *node = [[GCNode alloc] initWithTag:_tag 
                                         value:[self stringValue]
                                          xref:[[self class] xrefForObject:self]
                                      subNodes:subNodes];
    
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

#pragma mark Properties

- (NSString *)type
{
    return [_tag name];
}

@synthesize value = _value;

- (void)setStringValue:(NSString *)stringValue
{
    _value = [[GCValue alloc] initWithType:GCStringValue value:stringValue];
}

- (NSString *)stringValue
{
    return [_value stringValue];
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    _value = [[GCValue alloc] initWithType:GCNumberValue value:numberValue];
}

- (NSNumber *)numberValue
{
    return [_value numberValue];
}

- (void)setAgeValue:(GCAge *)ageValue
{
    _value = [[GCValue alloc] initWithType:GCAgeValue value:ageValue];
}

- (GCAge *)ageValue
{
    return [_value ageValue];
}

- (void)setDateValue:(GCDate *)dateValue
{
    _value = [[GCValue alloc] initWithType:GCDateValue value:dateValue];
}

- (GCDate *)dateValue
{
    return [_value dateValue];
}

@end
