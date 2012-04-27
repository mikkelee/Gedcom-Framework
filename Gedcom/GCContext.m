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
	NSMutableDictionary *xrefBlocks;
}

- (id)init
{
	self = [super init];
	
	if (self) {
        xrefStore = [NSMutableDictionary dictionary];
        xrefBlocks = [NSMutableDictionary dictionary];
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
	
	if ([xrefBlocks objectForKey:xref]) {
		for (void (^block) (NSString *) in [xrefBlocks objectForKey:xref]) {
			block(xref);
		}
		[xrefBlocks removeObjectForKey:xref];
	}
}

- (NSString *)xrefForEntity:(GCEntity *)obj
{
    NSString *xref = [xrefStore objectForKey:[NSValue valueWithPointer:(const void *)obj]];
    
    if (xref == nil) {
        int i = 0;
        do {
            xref = [NSString stringWithFormat:@"@%@%d@", [[obj gedTag] code], ++i]; 
        } while ([[xrefStore allKeysForObject:xref] count] > 0);
        
        [self storeXref:xref forEntity:obj];
    }
    
    return xref;
}

- (GCEntity *)entityForXref:(NSString *)xref
{
	return [[[xrefStore allKeysForObject:xref] lastObject] pointerValue];
}

- (void)registerXref:(NSString *)xref forBlock:(void (^)(NSString *xref))block
{
	if ([self entityForXref:xref]) {
		block(xref);
	} else	if ([xrefBlocks objectForKey:xref]) {
		[[xrefBlocks objectForKey:xref] addObject:block];
	} else {
		[xrefBlocks setObject:[NSMutableSet setWithObject:block] forKey:xref];
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: %@", [super description], xrefStore];
}

@end
