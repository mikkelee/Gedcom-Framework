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
        [entity addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    [self didChangeValueForKey:@"entity"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observed: %@ %@ %@ %@", keyPath, object, change, context);
}

@end

@interface GCKeyValueTests : SenTestCase
@end

@implementation GCKeyValueTests

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
    
    
}


@end
