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
    GCNoteEntity *note = [GCNoteEntity noteInContext:context];
    
    //[note setGedValue]
    
    [object addRelationshipWithType:@"noteReference" target:note];
}

@end

@interface GCDelegateTests : SenTestCase
@end

@implementation GCDelegateTests

- (void)testUnknownTag
{
    GCContextDelegateTester *delegate = [[GCContextDelegateTester alloc] init];
    GCContext *ctx = [[GCContext alloc] init];
    
    [ctx setDelegate:delegate];
    
    NSString *gedcomString =
    @"0 HEAD\n"
    @"0 @F1@ FAM\n"
    @"1 _UMR Y\n"
    @"0 TRLR";
    
    NSString *expected =
    @"0 HEAD\n"
    @"0 @F1@ FAM\n"
    @"1 NOTE @NOTE1@\n"
    @"0 @NOTE1@ NOTE\n"
    //@"1 CONC Unmarried.\n" //TODO note values not possible yet... :(
    @"0 TRLR";
    
    [ctx parseNodes:[GCNode arrayOfNodesFromString:gedcomString]];
    
    STAssertEqualObjects([ctx gedcomString], expected, nil);
}

@end
