//
//  Document.h
//  GedcomGUI
//
//  Created by Mikkel Eide Eriksen on 12/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Gedcom/Gedcom.h>
#import "GCTreeView.h"

@interface Document : NSDocument <GCContextDelegate> {
    IBOutlet NSArrayController *_individualsController;
    
    IBOutlet NSPredicateEditor *_individualsPredicateEditor;
    
    IBOutlet GCTreeView *_treeView;
}

- (IBAction)testLog:(id)sender;
- (IBAction)treeTest:(id)sender;

- (IBAction)updatePredicates:(id)sender;

@property (readonly) GCContext *context;
@property id individuals;
@property NSPredicate *individualsPredicate;

@end
