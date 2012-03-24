//
//  GCObject.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"
#import "GCNode.h"
#import "GCTag.h"

@implementation GCObject {
    NSString *_type;
}

- (id)initWithType:(NSString *)type
{
    self = [super init];
    
    if (self) {
        _type = type;
    }
    
    return self;    
}

+ (id)objectWithType:(NSString *)type
{
    return [[self alloc] initWithType:type];
}

- (void)addRecord:(GCObject *)object
{
    
}

- (GCNode *)gedcomNode
{
    GCTag *tag = [GCTag tagNamed:_type];
    
    GCNode *node = [[GCNode alloc] initWithTag:tag xref:nil]; //TODO
    
    return node;
}

@end
