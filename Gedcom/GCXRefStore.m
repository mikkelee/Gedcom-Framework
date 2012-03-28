//
//  GCXRefStore.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCXrefStore.h"

#import "GCEntity.h"
#import "GCTag.h"

@implementation GCXrefStore

//TODO probably belongs in GCFile

__strong static NSMutableDictionary *xrefStore;

+ (void)setupXrefStore
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        xrefStore = [NSMutableDictionary dictionaryWithCapacity:4];
    });
}

+ (void)storeXref:(NSString *)xref forEntity:(GCEntity *)obj
{
    [self setupXrefStore];
    [xrefStore setObject:xref forKey:[NSValue valueWithPointer:(const void *)obj]];
}

+ (NSString *)xrefForEntity:(GCEntity *)obj
{
    [self setupXrefStore];
    NSString *xref = [xrefStore objectForKey:[NSValue valueWithPointer:(const void *)obj]];
    
    if (xref == nil) {
        int i = 0;
        do {
            xref = [NSString stringWithFormat:@"@%@%d@", [[GCTag tagNamed:[obj type]] code], ++i]; 
        } while ([[xrefStore allKeysForObject:xref] count] > 0);
        
        [self storeXref:xref forEntity:obj];
    }
    
    return xref;
}

+ (GCEntity *)entityForXref:(NSString *)xref
{
	return [[xrefStore allKeysForObject:xref] lastObject];
}

@end
