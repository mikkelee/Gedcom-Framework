//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCRecord.h"
#import "GCNode.h"
#import "GCTag.h"
#import "GCValue.h"
#import "GCAge.h"
#import "GCDate.h"

@implementation GCRecord {
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

+ (void)storeXref:(NSString *)xref forObject:(GCRecord *)obj
{
    [self setupXrefStore];
    [xrefStore setObject:xref forKey:[NSValue valueWithPointer:(const void *)obj]];
}

+ (NSString *)xrefForObject:(GCRecord *)obj
{
    [self setupXrefStore];
    NSString *xref = [xrefStore objectForKey:[NSValue valueWithPointer:(const void *)obj]];
    
    if (xref == nil && [[GCTag tagForAlias:[GCTag tagForName:[obj type]]] isEqualToString:@"@reco"]) {
        int i = 0;
        do {
            xref = [NSString stringWithFormat:@"@%@%d@", [GCTag tagForName:[obj type]], ++i]; 
        } while ([[xrefStore allKeysForObject:xref] count] > 0);
        
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
    GCRecord *new = [self objectWithType:type];
    
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

+ (id)objectWithType:(NSString *)type boolValue:(BOOL)value
{
    return [self objectWithType:type 
                          value:[[GCValue alloc] initWithType:GCBoolValue value:[NSNumber numberWithBool:value]]]; 
}

+ (id)objectWithType:(NSString *)type object:(GCRecord *)object
{
    return [self objectWithType:type 
                          value:[[GCValue alloc] initWithType:GCStringValue value:[GCRecord xrefForObject:object]]]; 
}

+ (id)objectWithGedcomNode:(GCNode *)node
{
    GCRecord *object = [[GCRecord alloc] initWithType:[[node gedTag] name]];
    
    if ([node xref]) {
        [[self class] storeXref:[node xref] forObject:object];
    }
    
    if ([node gedValue] != nil) {
        switch ([[node gedTag] valueType]) {
            case GCStringValue:
                [object setStringValue:[node gedValue]];
                break;
                
            case GCNumberValue: {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [object setNumberValue:[formatter numberFromString:[node gedValue]]];
            }
                break;
                
            case GCAgeValue:
                [object setAgeValue:[GCAge ageFromGedcom:[node gedValue]]];
                break;
                
            case GCDateValue:
                [object setDateValue:[GCDate dateFromGedcom:[node gedValue]]];
                break;
                
            case GCBoolValue:
                [object setBoolValue:[[node gedValue] isEqualToString:@"Y"]];
                break;
                
            case GCRecordReferenceValue:
                //TODO
                break;
                
            default:
                break;
        }
    }
    
    for (id subNode in [node subNodes]) {
        [object addRecord:[GCRecord objectWithGedcomNode:subNode]];
    }
    
    return object;
}

- (void)addRecord:(GCRecord *)object
{
    id key = [object type];
    
    NSParameterAssert([[self validSubRecordTypes] containsObject:key]);
    
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

- (void)addRecordWithType:(NSString *)type boolValue:(BOOL)value
{
    [self addRecord:[[self class] objectWithType:type boolValue:value]];
}

- (void)addRecordWithType:(NSString *)type dateValue:(GCDate *)value
{
    [self addRecord:[[self class] objectWithType:type dateValue:value]];
}

- (void)addRecordWithType:(NSString *)type object:(GCRecord *)object
{
    [self addRecord:[[self class] objectWithType:type object:object]];
}

- (GCNode *)gedcomNode
{
    NSMutableArray *subNodes = [NSMutableArray arrayWithCapacity:3];
    
    for (id subTag in [_tag validSubTags]) {
        //NSLog(@"subTag: %@", subTag);
        id obj = [_records objectForKey:[GCTag nameForTag:subTag]];
        
        if (obj) {
            //NSLog(@"obj: %@", obj);
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                NSArray *sorted = [obj sortedArrayUsingComparator:^(id obj1, id obj2) {
                    return [[obj1 stringValue] compare:[obj2 stringValue]];
                }];
                for (id subObj in sorted) {
                    //NSLog(@"subObj: %@", subObj);
                    [subNodes addObject:[subObj gedcomNode]];
                }
            } else {
                [subNodes addObject:[obj gedcomNode]];
            }
        }
    }
    
    GCNode *node = [[GCNode alloc] initWithTag:_tag 
                                         value:[self stringValue]
                                          xref:[[self class] xrefForObject:self]
                                      subNodes:subNodes];
    
    return node;
}

- (NSArray *)validSubRecordTypes
{
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:[[_tag validSubTags] count]];
    
    for (id tag in [_tag validSubTags]) {
        [types addObject:[GCTag nameForTag:tag]];
    }
    
    //NSLog(@"types: %@", types);
    
    return types;
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

- (void)setBoolValue:(BOOL)boolValue
{
    _value = [[GCValue alloc] initWithType:GCBoolValue value:[NSNumber numberWithBool:boolValue]];
}

- (BOOL)boolValue
{
    return [_value boolValue];
}

@end
