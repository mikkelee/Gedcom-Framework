//
//  GCXRefStore.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext.h"

#import "GCEntity.h"
#import "GCTag.h"

@implementation GCContext {
	NSMutableDictionary *xrefStore;
}

- (id)init
{
	self = [super init];
	
	if (self) {
        xrefStore = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	
	return self;
}

+ (id)context
{
	return [[self alloc] init];
}

- (void)storeXref:(NSString *)xref forEntity:(GCEntity *)obj
{
	[xrefStore setObject:xref forKey:[NSValue valueWithPointer:(const void *)obj]];
}

- (NSString *)xrefForEntity:(GCEntity *)obj
{
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

- (GCEntity *)entityForXref:(NSString *)xref
{
	return [[xrefStore allKeysForObject:xref] lastObject];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: %@", [super description], xrefStore];
}

@end
