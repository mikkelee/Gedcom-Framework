//
//  GCTreeView.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 20/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCIndividualRecord;

@interface GCTreeView : NSView

@property (nonatomic, strong) IBOutlet GCIndividualRecord *rootIndividual;

@end