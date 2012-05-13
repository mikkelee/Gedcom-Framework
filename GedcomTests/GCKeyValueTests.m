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
    
    GCProperty *name1 = [GCAttribute attributeWithType:@"name" value:[GCString valueWithGedcomString:@"Jens /Hansen/"]];
    GCProperty *name2 = [GCAttribute attributeWithType:@"name" value:[GCString valueWithGedcomString:@"Jens /Jensen/"]];
    
    GCProperty *nickname = [GCAttribute attributeWithType:@"nickname" value:[GCString valueWithGedcomString:@"Store Jens"]];
    
    [name1 addProperty:nickname];
    
    STAssertEqualObjects([nickname describedObject], name1, nil);
    STAssertTrue([[name1 properties] containsObject:nickname], nil);
    STAssertFalse([[name2 properties] containsObject:nickname], nil);
    
    [name2 addProperty:nickname];
    
    STAssertEqualObjects([nickname describedObject], name2, nil);
    STAssertTrue([[name2 properties] containsObject:nickname], nil);
    STAssertFalse([[name1 properties] containsObject:nickname], nil);
    
    [indi setValue:[NSArray arrayWithObjects:name1, name2, nil] forKey:@"name"];
    
    STAssertEqualObjects([indi valueForKeyPath:@"name.nickname"], [NSOrderedSet orderedSetWithObject:nickname], nil);
}

-(void)testKVO
{
    GCTestObserver *observer = [[GCTestObserver alloc] init];
    
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
    
    [observer setEntity:indi];
    
    NSArray *names = [NSArray arrayWithObjects:
                      [GCString valueWithGedcomString:@"Jens /Hansen/"], 
                      [GCString valueWithGedcomString:@"Jens /Hansen/ Smed"], 
                      nil];
    
    [indi setValue:names 
            forKey:@"name"];
    
    //TODO should this fire something too?
    [[[indi valueForKey:@"name"] objectAtIndex:1] setValue:[GCString valueWithGedcomString:@"Store Jens"] forKey:@"nickname"];
    
    [[indi mutableOrderedSetValueForKey:@"name"] removeObjectAtIndex:0];
    
    NSArray *observations = [NSArray arrayWithObjects:
                             // NSKeyValueChange : old : new
                             @"2 : (null) : 0 NAME Jens /Hansen/",
                             @"2 : (null) : 0 NAME Jens /Hansen/ Smed",
                             @"3 : 0 NAME Jens /Hansen/ : (null)",
                             nil];
    STAssertEqualObjects([observer observations], 
                         observations,
                         nil);
}

@end
