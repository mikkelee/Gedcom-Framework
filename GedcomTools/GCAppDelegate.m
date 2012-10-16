//
//  GCAppDelegate.m
//  GedcomTools
//
//  Created by Mikkel Eide Eriksen on 10/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCAppDelegate.h"

@implementation GCAppDelegate {
    GCContext *ctx;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

#pragma mark GCContextDelegate methods

- (void)context:(GCContext *)context willParseNodes:(NSUInteger)nodeCount
{
    [_loadingProgress setIndeterminate:NO];
    [_loadingProgress setMaxValue:nodeCount];
}

- (void)context:(GCContext *)context didUpdateEntityCount:(NSUInteger)entityCount
{
    [_loadingProgress incrementBy:(entityCount - [_loadingProgress doubleValue])];
}

- (void)context:(GCContext *)context didFinishWithEntityCount:(NSUInteger)entityCount
{
    [_loadingProgress incrementBy:(entityCount - [_loadingProgress doubleValue])];
    
    [_statusLabel setStringValue:@"Validating..."];
    [_loadingProgress setIndeterminate:YES];
    [_loadingProgress startAnimation:self];
    
    NSError *error = nil;
    
    BOOL result = [ctx validateContext:&error];
    
    if (!result) {
        [_resultView setString:[error description]];
    } else {
        [_resultView setString:@"File is valid!"];
    }
    
    [_statusLabel setStringValue:@"Done."];
    [_loadingProgress stopAnimation:self];
    [_testButton setEnabled:YES];
}

#pragma mark IBActions

- (IBAction)doTest:(id)sender
{
    ctx = [GCContext context];
    
    [ctx setDelegate:self];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    // Ask the user for the files to burn.
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setResolvesAliases:YES];
    [openPanel setDelegate:self];
    [openPanel setTitle:@"Select a Gedcom file to test."];
    [openPanel setPrompt:@"Select"];
    
    if ([openPanel runModal] == NSOKButton)
    {
        [_resultView setString:@""];
        [_statusLabel setStringValue:@"Loading..."];
        [_loadingProgress setIndeterminate:YES];
        [_loadingProgress startAnimation:self];
        [_testButton setEnabled:NO];
        
        NSData *data = [NSData dataWithContentsOfFile:[((NSURL *)[[openPanel URLs] objectAtIndex:0]) path]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            
            BOOL didLoad = [ctx parseData:data error:&error];
            
            if (!didLoad) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_statusLabel setStringValue:@"Error loading file."];
                    [_loadingProgress stopAnimation:self];
                    [_testButton setEnabled:YES];
                    [_resultView setString:[error description]];
                });
            }
        });
    }
}

@end
