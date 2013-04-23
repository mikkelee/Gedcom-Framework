//
//  GCDelegateTests.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 12/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Gedcom.h"

@interface GCContextDelegateTester : NSObject <GCContextDelegate>
@end

@implementation GCContextDelegateTester

- (BOOL)context:(GCContext *)context shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object
{
    GCNoteRecord *note = [GCNoteRecord noteInContext:context];
    
    note.value = [GCString valueWithGedcomString:@"Unmarried."];
    
    [object addRelationshipWithType:@"noteReference" target:note];
    
    return NO;
}

@end

@interface GCDelegateTests : SenTestCase
@end

@implementation GCDelegateTests

- (void)testUnknownTag
{
    GCContextDelegateTester *delegate = [[GCContextDelegateTester alloc] init];
    GCContext *ctx = [GCContext context];
    
    ctx.delegate = delegate;
    
    NSString *gedcomString =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @F1@ FAM\n"
    @"1 _UMR Y\n"
    @"0 TRLR";
    
    NSError *error = nil;
    
    BOOL succeeded = [ctx parseData:[gedcomString dataUsingEncoding:NSASCIIStringEncoding] error:&error];
    
    STAssertTrue(succeeded, nil);
    STAssertNil(error, nil);
    
    NSString *expected =
    @"0 HEAD\n"
    @"1 CHAR ASCII\n"
    @"0 @F1@ FAM\n"
    @"1 NOTE @NOTE1@\n"
    @"0 @NOTE1@ NOTE\n"
    @"1 CONC Unmarried.\n"
    @"0 TRLR";
    
    STAssertEqualObjects(ctx.gedcomString, expected, nil);
}

@end
