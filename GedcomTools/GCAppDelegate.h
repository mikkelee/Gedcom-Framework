//
//  GCAppDelegate.h
//  GedcomTools
//
//  Created by Mikkel Eide Eriksen on 10/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Gedcom/Gedcom.h>

@interface GCAppDelegate : NSObject <NSApplicationDelegate, GCContextDelegate, NSOpenSavePanelDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSProgressIndicator *loadingProgress;

@property (assign) IBOutlet NSButton *testButton;

@property (assign) IBOutlet NSTextView *resultView;

- (IBAction)doTest:(id)sender;

@end
