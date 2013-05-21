//
//  GCTreeView.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 20/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTreeView.h"
#import <Gedcom/Gedcom.h>

#import "GCIndividualDetailViewController.h"

@implementation GCTreeView {
    NSMutableArray *_subViewControllers;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        _subViewControllers = [NSMutableArray array];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (void)setupIndividual:(GCIndividualRecord *)individual;
{
    GCIndividualDetailViewController *vc = [[GCIndividualDetailViewController alloc] init];
    
    vc.individual = individual;
    
    [_subViewControllers addObject:vc];
    
    [self addSubview:[vc view]];
    
    /*
    id father = [individual valueForKey:@"father"];
    if (father) {
        [self setupIndividual:father];
    }
    id mother = [individual valueForKey:@"mother"];
    if (mother) {
        [self setupIndividual:mother];
    }
    */
}

- (void)teardown
{
    for (NSViewController *vc in _subViewControllers) {
        [[vc view] removeFromSuperview];
    }
    _subViewControllers = [NSMutableArray array];
}

- (void)setRootIndividual:(GCIndividualRecord *)rootIndividual
{
    _rootIndividual = rootIndividual;
    
    // TODO: only when necessary:
    [self teardown];
    [self setupIndividual:_rootIndividual];
}

@end