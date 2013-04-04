//
//  Document.m
//  GedcomGUI
//
//  Created by Mikkel Eide Eriksen on 12/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "Document.h"
#import <Gedcom/Gedcom.h>

#import "GCGUIAdditions.h"

@interface Document ()

@property GCContext *context;

@end

@implementation Document {
    BOOL _isEntireFileLoaded;
    NSMutableArray *_individuals;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isEntireFileLoaded = NO;
        _individuals = [NSMutableArray array];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return NO; //TODO
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
    NSParameterAssert([typeName isEqualToString:@"Gedcom .ged file"]);
    
    [self performSelector:@selector(parseData:) withObject:data afterDelay:0.0f];
    
    return YES;
}

- (BOOL)isEntireFileLoaded
{
    return _isEntireFileLoaded;
}

#pragma mark -

- (void)parseData:(NSData *)data
{
    //TODO sheet is broken with multiple docs open; should probably be moved to its own .nib
    [NSApp beginSheet:loadingSheet modalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:NULL contextInfo:nil];
    
    [currentlyLoadingSpinner setUsesThreadedAnimation:YES];
    [currentlyLoadingSpinner startAnimation:nil];
    
    self.context = [GCContext context];
    
    [self.context setDelegate:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.context parseData:data error:nil];
    });
}

#pragma mark IBActions

- (IBAction)testLog:(id)sender
{
    [individualsPredicateEditor addRow:nil];
    //NSLog(@"header: %@", self.context.header);
}

- (IBAction)updatePredicates:(id)sender
{
    if (sender == individualsPredicateEditor) {
        self.individualsPredicate = [individualsPredicateEditor predicate];
    }
}

#pragma mark NSTextViewDelegate methods

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
    if ([[link scheme] isEqualToString:@"xref"]) {
        GCEntity *entity = [GCContext entityForURL:link];
        
        return [entity.type isEqualToString:@"individual"] && [individualsController setSelectedObjects:@[entity]];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:link];
        
        return YES;
    }
}

#pragma mark GCContextDelegate methods

- (void)context:(GCContext *)context didUpdateEntityCount:(NSUInteger)entityCount
{
    if (entityCount < 100 || entityCount % 100 == 0) {
        [recordCountField setIntegerValue:entityCount];
    }
}

- (void)context:(GCContext *)context didParseNodesWithEntityCount:(NSUInteger)entityCount
{
    [recordCountField setIntegerValue:entityCount];
    
    [currentlyLoadingSpinner stopAnimation:nil];
    _isEntireFileLoaded = YES;
    
    [NSApp endSheet:loadingSheet];
    [loadingSheet orderOut:nil];
    
    // TODO bind array controller to s.c.i instead
    self.individuals = self.context.individuals;
    
    [individualsPredicateEditor setRowTemplates:[GCIndividualEntity defaultPredicateEditorRowTemplates]];
}

- (void)context:(GCContext *)context didReceiveActionForEntity:(GCEntity *)entity
{
    NSLog(@"Clicked: %@", entity);
    
    [entity.type isEqualToString:@"individual"] && [individualsController setSelectedObjects:@[entity]];
}

@end
