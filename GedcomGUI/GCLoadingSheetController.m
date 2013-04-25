//
//  GCLoadingSheetController.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCLoadingSheetController.h"

#import <math.h>

@interface GCLoadingSheetController ()

@end

@implementation GCLoadingSheetController

- (id)init
{
    self = [super initWithWindowNibName:@"LoadingSheet"];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithWindowNibName:(NSString *)name
{
    NSLog(@"External clients are not allowed to call -[%@ initWithWindowNibName:] directly!", [self class]);
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (void)startForWindow:(NSWindow *)window
{
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];
    
    [currentlyLoadingSpinner setUsesThreadedAnimation:YES];
    [currentlyLoadingSpinner startAnimation:nil];
}

- (void)updateWithCount:(NSUInteger)count
{
    if ( (rand()%1000) < 3) {
        [recordCountField setIntegerValue:count];
    }
}

- (void)stop
{
    [NSApp endSheet:self.window];
    
    [currentlyLoadingSpinner stopAnimation:nil];
    
    [self.window orderOut:nil];
}

@end
