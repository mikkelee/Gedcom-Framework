//
//  GCNode.h
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCTag;

@interface GCNode : NSObject <NSCopying, NSCoding>

- (id)init;

//TODO initWith:

+ (NSArray *)arrayOfNodesFromString:(NSString*) gedString;
+ (NSArray *)arrayOfNodesFromArrayOfStrings:(NSArray*) gedLines;

- (NSString *)gedcomString;
- (NSArray *)gedcomLines;

-(GCNode *)subNodeForTag:(NSString *)tag;
-(NSArray *)subNodesForTag:(NSString *)tag;

-(GCNode *)subNodeForTagPath:(NSString *)tagPath; //tagPath can be for instance BIRT.DATE
-(NSArray *)subNodesForTagPath:(NSString *)tagPath;

@property (readonly) GCNode *parent;
@property (readonly) GCTag *gedTag;
@property (readonly) NSString *gedValue;
@property (readonly) NSString *xref;
@property (readonly) NSString *lineSeparator;
@property (readonly) NSArray *subNodes;

@end

