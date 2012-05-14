//
//  Document.h
//  GedcomGUI
//
//  Created by Mikkel Eide Eriksen on 12/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument {
    IBOutlet NSWindow *mainWindow;

    IBOutlet NSWindow *loadingSheet;
    
    IBOutlet NSTextField *recordCountField;
    IBOutlet NSProgressIndicator *currentlyLoadingSpinner;
    
    
}

- (IBAction)testLog:(id)sender;

@property id individuals;

@end
