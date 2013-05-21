//
//  GCIndividualDetailViewController.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 21/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCIndividualRecord;

@interface GCIndividualDetailViewController : NSViewController

@property (nonatomic, strong) IBOutlet GCIndividualRecord *individual;


@end
