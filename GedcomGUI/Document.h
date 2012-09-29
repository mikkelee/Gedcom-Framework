//
//  Document.h
//  GedcomGUI
//
//  Created by Mikkel Eide Eriksen on 12/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Gedcom/Gedcom.h>

@interface Document : NSDocument <GCContextDelegate> {
    IBOutlet NSWindow *mainWindow;
    
    IBOutlet NSArrayController *individualsController;

    IBOutlet NSWindow *loadingSheet;
    
    IBOutlet NSTextField *recordCountField;
    IBOutlet NSProgressIndicator *currentlyLoadingSpinner;
    
    IBOutlet NSPredicateEditor *individualsPredicateEditor;
}

- (IBAction)testLog:(id)sender;

- (IBAction)updatePredicates:(id)sender;

@property (readonly) GCContext *context;
@property id individuals;
@property NSPredicate *individualsPredicate;

@end
