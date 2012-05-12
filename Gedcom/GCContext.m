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
    NSMutableSet *storedEntities; //to avoid expensive allKeysForObject: calls if we don't have it stored
}

- (id)init
{
	self = [super init];
	
	if (self) {
        xrefStore = [NSMutableDictionary dictionary];
        xrefBlocks = [NSMutableDictionary dictionary];
        storedEntities = [NSMutableSet set];
	}
	
	return self;
}

+ (id)context
{
	return [[self alloc] init];
}

- (void)setXref:(NSString *)xref forEntity:(GCEntity *)obj
{
    NSParameterAssert(xref);
    
    if ([storedEntities containsObject:obj]) {
        for (NSString *key in [xrefStore allKeysForObject:obj]) {
            [xrefStore removeObjectForKey:key];
        }
    }
    
    //NSLog(@"Storing %@ for %@", xref, obj);
    
    [xrefStore setObject:obj forKey:xref];
    [storedEntities addObject:obj];
	
	if ([xrefBlocks objectForKey:xref]) {
		for (void (^block) (NSString *) in [xrefBlocks objectForKey:xref]) {
			block(xref);
		}
		[xrefBlocks removeObjectForKey:xref];
	}
}

- (NSString *)xrefForEntity:(GCEntity *)obj
{
    if (!obj) {
        return nil;
    }
    NSParameterAssert([[obj gedTag] code]);
    
    //NSLog(@"looking for %@ in %@", obj, self);
    
    NSString *xref = nil;
    for (NSString *key in [xrefStore allKeys]) {
        //NSLog(@"%@: %@", key, [xrefStore objectForKey:key]);
        if ([xrefStore objectForKey:key] == obj) {
            xref = key;
        }
    }
    
    if (xref == nil) {
        int i = 0;
        do {
            xref = [NSString stringWithFormat:@"@%@%d@", [[obj gedTag] code], ++i]; 
        } while ([xrefStore objectForKey:xref]);
        
        [self setXref:xref forEntity:obj];
    }
    
    //NSLog(@"xref: %@", xref);
    
    return xref;
}

- (GCEntity *)entityForXref:(NSString *)xref
{
    return [xrefStore objectForKey:xref];
}

- (void)registerBlock:(void (^)(NSString *xref))block forXref:(NSString *)xref
{
    NSParameterAssert(xref);
    
	if ([self entityForXref:xref]) {
		block(xref);
	} else	if ([xrefBlocks objectForKey:xref]) {
		[[xrefBlocks objectForKey:xref] addObject:block];
	} else {
		[xrefBlocks setObject:[NSMutableSet setWithObject:block] forKey:xref];
	}
}

#pragma mark NSCoding conformance

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        xrefStore = [aDecoder decodeObjectForKey:@"xrefStore"];
        xrefBlocks = [aDecoder decodeObjectForKey:@"xrefBlocks"];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:xrefStore forKey:@"xrefStore"];
    [aCoder encodeObject:xrefBlocks forKey:@"xrefBlocks"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (xrefStore: %@)", [super description], xrefStore];
}
//COV_NF_END

@end
