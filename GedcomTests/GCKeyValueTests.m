//
//  GCDateTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 16/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"
#import <objc/runtime.h>

@interface GCTestObserver : NSObject

- (NSArray *)observations;

@property GCEntity *entity;

@end

@implementation GCTestObserver {
    GCEntity *_entity;
    NSMutableArray *_observations;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _observations = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

-(GCEntity *)entity
{
    return _entity;
}

-(void)setEntity:(GCEntity *)entity
{
    [self willChangeValueForKey:@"entity"];
    _entity = entity;
    for (NSString *key in [_entity validProperties]) {
        //NSLog(@"Observing: %@", key);
        [_entity addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    [self didChangeValueForKey:@"entity"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id old = [NSNull null];
    if ([change valueForKey:NSKeyValueChangeOldKey]) {
        if (![[change valueForKey:NSKeyValueChangeOldKey] isKindOfClass:[NSNull class]]) { 
            old = [[[change valueForKey:NSKeyValueChangeOldKey] lastObject] gedcomString];
        }
        if (!old) old = [NSNull null];
    }
    
    id new = [NSNull null];
    if ([change valueForKey:NSKeyValueChangeNewKey]) {
        if (![[change valueForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) { 
            new = [[[change valueForKey:NSKeyValueChangeNewKey] lastObject] gedcomString];
        }
        if (!new) new = [NSNull null];
    }
    
    if ([[change valueForKey:NSKeyValueChangeKindKey] intValue] == 1 && [old isEqualTo:new]) {
        return;
    }
    
    //NSLog(@"Observed: %@ %@ %@ %@", keyPath, object, change, context);
    
    NSArray *observation = [NSArray arrayWithObjects:keyPath,
                            [change valueForKey:NSKeyValueChangeKindKey], 
                            old, 
                            new, 
                            nil];
    NSString *observationString = [observation componentsJoinedByString:@" : "];
    [_observations addObject:observationString];
}

- (NSArray *)observations
{
    return [_observations copy];
}

-(void)dealloc
{
    for (NSString *key in [_entity validProperties]) {
        //NSLog(@"Deobserving: %@", key);
        [_entity removeObserver:self forKeyPath:key];
    }
}

@end

@interface GCKeyValueTests : SenTestCase
@end

@implementation GCKeyValueTests

-(void)testValueForKey
{
	GCNode *aNode = [GCNode nodeWithTag:@"NAME" value:@"Jens /Hansen/"];
	
	GCNode *bNode = [[GCNode alloc] initWithTag:@"INDI" 
										  value:nil 
										   xref:@"@I1@" 
									   subNodes:[NSArray arrayWithObject:aNode]];
	
	STAssertEqualObjects(aNode, [bNode valueForKey:@"NAME"], nil);
}

- (void)testKVC1
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individual" inContext:ctx];
    
    [[indi allProperties] addObject:[GCAttribute attributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]]];
    
    NSDate *knownDate = [NSDate dateWithNaturalLanguageString:@"Jan 1, 2000 12:00:00"];
    [indi setValue:knownDate forKey:@"lastModified"];
    
    STAssertEqualObjects([indi gedcomString], 
                         @"0 @INDI1@ INDI\n"
                         @"1 NAME Jens /Hansen/\n"
                         @"1 CHAN\n"
                         @"2 DATE 1 JAN 2000\n"
                         @"3 TIME 12:00:00"
                         , nil);
    
}

- (void)testKVC2
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individual" inContext:ctx];
    
    GCProperty *name1 = [GCAttribute attributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
    GCProperty *name2 = [GCAttribute attributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Jensen/"]];
    
    GCProperty *nickname = [GCAttribute attributeWithType:@"nickname" value:[GCString valueWithGedcomString:@"Store Jens"]];
    
    [[name1 mutableArrayValueForKey:@"properties"] addObject:nickname];
    
    STAssertEqualObjects([nickname describedObject], name1, nil);
    STAssertTrue([[name1 valueForKey:@"properties"] containsObject:nickname], nil);
    STAssertFalse([[name2 valueForKey:@"properties"] containsObject:nickname], nil);
    
    [[name2 mutableArrayValueForKey:@"properties"] addObject:nickname];
    
    STAssertEqualObjects([nickname describedObject], name2, nil);
    STAssertTrue([[name2 valueForKey:@"properties"] containsObject:nickname], nil);
    STAssertFalse([[name1 valueForKey:@"properties"] containsObject:nickname], nil);
    
    [indi setValue:[NSArray arrayWithObjects:name1, name2, nil] forKey:@"personalNames"];
    
    NSArray *expectedObjects = [NSArray arrayWithObjects:[NSNull null], nickname, nil];
    STAssertEqualObjects([indi valueForKeyPath:@"personalNames.nickname"], expectedObjects, nil);
}

-(void)testKVO
{
    GCTestObserver *observer = [[GCTestObserver alloc] init];
    
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individual" inContext:ctx];
    
    [observer setEntity:indi];
    
    [[indi mutableArrayValueForKey:@"personalNames"] addObject:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
    [[indi mutableArrayValueForKey:@"personalNames"] addObject:[GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"]];
    
    //TODO should this fire something too?
    [[[indi valueForKey:@"personalNames"] objectAtIndex:1] setValue:[GCString valueWithGedcomString:@"Store Jens"] forKey:@"nickname"];
    
    [[indi mutableOrderedSetValueForKey:@"personalNames"] removeObjectAtIndex:0];
    
    //broken
    /*
    NSArray *expectedObservations = [NSArray arrayWithObjects:
                                     // NSKeyValueChange : old : new
                                     @"personalName : 2 : <null> : 0 NAME Jens /Hansen/",
                                     @"personalName : 2 : <null> : 0 NAME Jens /Hansen/ Smed",
                                     @"personalName : 3 : 0 NAME Jens /Hansen/ : <null>",
                                     nil];
    STAssertEqualObjects([observer observations], 
                         expectedObservations,
                         nil);*/
}

- (void)testSetGedcomString
{
    GCTestObserver *observer = [[GCTestObserver alloc] init];

	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individual" inContext:ctx];
    
    [indi setGedcomString:@"0 @INDI1@ INDI\n"
     @"1 NAME Jens /Hansen/\n"
     @"1 NAME Jens /Hansen/ Smed\n"
     @"1 BIRT\n"
     @"2 DATE 1 JAN 1901\n"
     @"1 DEAT Y"];
    
    [observer setEntity:indi];
    
    [indi setGedcomString:@"0 @INDI1@ INDI\n"
     @"1 NAME Jens /Hansen/\n"
     @"1 NAME Jens /Hansen/ Smed\n"
     @"1 DEAT\n"
     @"2 DATE 1 JAN 1930"];
    
    //broken
    /*
    NSArray *expectedObservations = [NSArray arrayWithObjects:
                                     // NSKeyValueChange : old : new
                                     @"birth : 2 : (null) : 0 BIRT",
                                     @"death : 2 : (null) : 0 DEAT Y",
                                     @"death : 3 : 0 DEAT : (null)",
                                     nil];
    STAssertEqualObjects([observer observations], 
                         expectedObservations,
                         nil);*/
}

- (void)AtestAAA
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individual" inContext:ctx];
    
    [indi setValue:[GCGender valueWithGedcomString:@"M"] forKey:@"sex"];
    
    NSMutableArray *names = [indi mutableArrayValueForKey:@"personalNames"];
    
    GCAttribute *name = [GCAttribute attributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
    
    NSLog(@"PRIOR ******");
    
    NSLog(@"name describedObject: %@", [name describedObject]);
    NSLog(@"indi: %@", indi);
    NSLog(@"names: %@", names);
    
    NSLog(@"ADDING ******");
    
    [names addObject:name];
    
    NSLog(@"name describedObject: %@", [name describedObject]);
    NSLog(@"indi: %@", indi);
    NSLog(@"names: %@", names);
    
    NSLog(@"REMOVING ******");
    
    [names removeObject:name];
    
    NSLog(@"name describedObject: %@", [name describedObject]);
    NSLog(@"indi: %@", indi);
    NSLog(@"names: %@", names);
    
}

@end
