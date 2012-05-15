//
//  GCDateTests.m
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 16/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

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
    //NSLog(@"Observed: %@ %@ %@ %@", keyPath, object, change, context);
    [_observations addObject:
     [NSString stringWithFormat:@"%@ : %@ : %@", 
      [change valueForKey:NSKeyValueChangeKindKey], 
      [[[change valueForKey:NSKeyValueChangeOldKey] lastObject] gedcomString], 
      [[[change valueForKey:NSKeyValueChangeNewKey] lastObject] gedcomString]]];
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

- (void)testKVC
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
    
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
    
    [indi setValue:[NSArray arrayWithObjects:name1, name2, nil] forKey:@"personalName"];
    
    NSArray *expectedObjects = [NSArray arrayWithObjects:[NSNull null], nickname, nil];
    STAssertEqualObjects([indi valueForKeyPath:@"personalName.nickname"], expectedObjects, nil);
}

-(void)testKVO
{
    GCTestObserver *observer = [[GCTestObserver alloc] init];
    
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
    
    [observer setEntity:indi];
    
    [[indi mutableArrayValueForKey:@"personalName"] addObject:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
    [[indi mutableArrayValueForKey:@"personalName"] addObject:[GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"]];
    
    //TODO should this fire something too?
    [[[indi valueForKey:@"personalName"] objectAtIndex:1] setValue:[GCString valueWithGedcomString:@"Store Jens"] forKey:@"nickname"];
    
    [[indi mutableOrderedSetValueForKey:@"personalName"] removeObjectAtIndex:0];
    
    NSArray *expectedObservations = [NSArray arrayWithObjects:
                             // NSKeyValueChange : old : new
                             @"2 : (null) : 0 NAME Jens /Hansen/",
                             @"2 : (null) : 0 NAME Jens /Hansen/ Smed",
                             @"3 : 0 NAME Jens /Hansen/ : (null)",
                             nil];
    STAssertEqualObjects([observer observations], 
                         expectedObservations,
                         nil);
}

- (void)testExperiment
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
    
    [[indi mutablePropertiesSet] addObject:[GCAttribute attributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]]];
    
    NSLog(@"valueForKey properties: %@", [indi valueForKey:@"properties"]);
    NSLog(@"propertiesSet: %@", [indi propertiesSet]);
    
}

@end
