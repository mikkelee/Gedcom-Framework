//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCEntity.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCProperty.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

@implementation GCEntity 

#pragma mark XRefs 

//TODO probably belongs in GCFile

__strong static NSMutableDictionary *xrefStore;

+ (void)setupXrefStore
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        xrefStore = [NSMutableDictionary dictionaryWithCapacity:4];
    });
}

+ (void)storeXref:(NSString *)xref forObject:(GCEntity *)obj
{
    [self setupXrefStore];
    [xrefStore setObject:xref forKey:[NSValue valueWithPointer:(const void *)obj]];
}

+ (NSString *)xrefForObject:(GCEntity *)obj
{
    [self setupXrefStore];
    NSString *xref = [xrefStore objectForKey:[NSValue valueWithPointer:(const void *)obj]];
    
    if (xref == nil) {
        int i = 0;
        do {
            xref = [NSString stringWithFormat:@"@%@%d@", [[GCTag tagNamed:[obj type]] code], ++i]; 
        } while ([[xrefStore allKeysForObject:xref] count] > 0);
        
        [self storeXref:xref forObject:obj];
    }
    
    return xref;
}

#pragma mark Convenience constructors

+ (id)entityWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

+ (id)entityWithGedcomNode:(GCNode *)node
{
    GCEntity *object = [[self alloc] initWithType:[[node gedTag] name]];
    
    for (id subNode in [node subNodes]) {
        [object addProperty:[GCProperty propertyWithGedcomNode:subNode]];
    }
    
    return object;
}

#pragma mark Properties

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:[self gedTag] 
								 value:nil
								  xref:[[self class] xrefForObject:self]
							  subNodes:[self subNodes]];
}

@end
