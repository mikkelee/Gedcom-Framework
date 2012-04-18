//
//  GCNode.h
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCTag;

@interface GCNode : NSObject <NSCopying, NSCoding>

#pragma mark Initialization

- (id)initWithTag:(GCTag *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSArray *)subNodes;

#pragma mark Convenience constructors

+ (id)nodeWithTag:(GCTag *)tag value:(NSString *)value;
+ (id)nodeWithTag:(GCTag *)tag xref:(NSString *)xref;

+ (id)nodeWithTag:(GCTag *)tag value:(NSString *)value subNodes:(NSArray *)subNodes;
+ (id)nodeWithTag:(GCTag *)tag xref:(NSString *)xref subNodes:(NSArray *)subNodes;

+ (NSArray *)arrayOfNodesFromString:(NSString*) gedString;
+ (NSArray *)arrayOfNodesFromArrayOfStrings:(NSArray*) gedLines;

#pragma mark Gedcom output

- (NSString *)gedcomString;
- (NSArray *)gedcomLines;

#pragma mark Objective-C properties

@property (readonly) GCNode *parent;
@property (readonly) GCTag *gedTag;
@property (readonly) NSString *gedValue;
@property (readonly) NSString *xref;
@property (readonly) NSString *lineSeparator;
@property (readonly) NSArray *subNodes;

@end

