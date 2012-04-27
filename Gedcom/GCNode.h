//
//  GCNode.h
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCNode : NSObject <NSCopying, NSCoding, NSMutableCopying>

#pragma mark Initialization

- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSArray *)subNodes;

#pragma mark Convenience constructors

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value;
+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref;

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value subNodes:(NSArray *)subNodes;
+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref subNodes:(NSArray *)subNodes;

+ (NSArray *)arrayOfNodesFromString:(NSString*) gedString;

#pragma mark Gedcom output

- (NSString *)gedcomString;
- (NSArray *)gedcomLines;

#pragma mark Objective-C properties

@property (readonly) GCNode *parent;
@property (readonly) NSString *gedTag;
@property (readonly) NSString *gedValue;
@property (readonly) NSString *xref;
@property (readonly) NSString *lineSeparator;
@property (readonly) NSArray *subNodes;

@end

