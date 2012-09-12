//
//  GCDelegateTests.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 12/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCContextDelegateTester : NSObject
@end

@implementation GCContextDelegateTester

- (void)context:(GCContext *)context didEncounterUnknownTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object
{
    NSLog(@"context: %@", context);
    NSLog(@"tag: %@", tag);
    NSLog(@"node: %@", node);
    NSLog(@"object: %@", object);
    return;
}

@end

@interface GCDelegateTests : SenTestCase
@end

@implementation GCDelegateTests

- (void)testUnknownTag
{
    GCContextDelegateTester *delegate = [[GCContextDelegateTester alloc] init];
    GCFile *gedcomFile = [[GCFile alloc] init];
    
    [[gedcomFile context] setDelegate:delegate];
    
    NSString *gedcomString = @"0 @F1@ FAM\n"
                             @"1 _UMR Y";
    
    [gedcomFile parseNodes:[GCNode arrayOfNodesFromString:gedcomString]];
}

@end
