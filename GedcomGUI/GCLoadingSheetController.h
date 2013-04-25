//
//  GCLoadingSheetController.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GCLoadingSheetController : NSWindowController {
    IBOutlet NSTextField *recordCountField;
    IBOutlet NSProgressIndicator *currentlyLoadingSpinner;
}

- (void)startForWindow:(NSWindow *)window;

- (void)updateWithCount:(NSUInteger)count;

- (void)stop;

@end
