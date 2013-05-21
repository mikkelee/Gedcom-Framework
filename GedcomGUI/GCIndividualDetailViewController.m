//
//  GCIndividualDetailViewController.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 21/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCIndividualDetailViewController.h"

@interface GCIndividualDetailViewController ()

@end

@implementation GCIndividualDetailViewController

- (id)init
{
    self = [super initWithNibName:@"GCIndividualDetailView" bundle:[NSBundle bundleForClass:[self class]]];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"External clients are not allowed to call -[%@ initWithWindowNibName:] directly!", [self class]);
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end
