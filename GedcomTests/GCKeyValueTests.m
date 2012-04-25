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

@property GCEntity *entity;

@end

@implementation GCTestObserver {
    GCEntity *_entity;
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
        NSLog(@"Observing: %@", key);
        [_entity addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    [self didChangeValueForKey:@"entity"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"Observed: %@ %@ %@ %@", keyPath, object, change, context);
}

-(void)dealloc
{
    for (NSString *key in [_entity validProperties]) {
        NSLog(@"Deobserving: %@", key);
        [_entity removeObserver:self forKeyPath:key];
    }
}

@end

@interface GCKeyValueTests : SenTestCase
@end

@implementation GCKeyValueTests

- (void)testKVC
{
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual record" inContext:ctx];
    
    GCProperty *name1 = [GCAttribute attributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
    GCProperty *name2 = [GCAttribute attributeWithType:@"Name" stringValue:@"Jens /Jensen/"];
    
    GCProperty *nickname = [GCAttribute attributeWithType:@"Nickname" stringValue:@"Store Jens"];
    
    [name1 addProperty:nickname];
    
    STAssertEqualObjects([nickname describedObject], name1, nil);
    STAssertTrue([[name1 properties] containsObject:nickname], nil);
    STAssertFalse([[name2 properties] containsObject:nickname], nil);
    
    [name2 addProperty:nickname];
    
    STAssertEqualObjects([nickname describedObject], name2, nil);
    STAssertTrue([[name2 properties] containsObject:nickname], nil);
    STAssertFalse([[name1 properties] containsObject:nickname], nil);
    
    [indi setValue:[NSArray arrayWithObjects:name1, name2, nil] forKey:@"Name"];
    
    STAssertEqualObjects([indi valueForKeyPath:@"Name.Nickname"], [NSOrderedSet orderedSetWithObject:nickname], nil);
}

-(void)testKVO
{
    GCTestObserver *observer = [[GCTestObserver alloc] init];
    
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual record" inContext:ctx];
    
    [observer setEntity:indi];
    
    NSArray *names = [NSArray arrayWithObjects:
                      [GCValue valueWithString:@"Jens /Hansen/"], 
                      [GCValue valueWithString:@"Jens /Hansen/ Smed"], 
                      nil];
    
    [indi setValue:names 
            forKey:@"Name"];
    
    //TODO this should fire something too(?)
    [[[indi valueForKey:@"Name"] objectAtIndex:1] setValue:[GCValue valueWithString:@"Store Jens"] forKey:@"Nickname"];
    
    [[indi valueForKey:@"Name"] removeObjectAtIndex:0];
}

@end
