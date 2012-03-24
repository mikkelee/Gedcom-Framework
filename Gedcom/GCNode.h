//
//  GCNode.h
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GCNode : NSObject <NSCopying, NSCoding>

- (id)init;

//TODO initWith:

+ (NSArray *)arrayOfNodesFromString:(NSString*) gedString;
+ (NSArray *)arrayOfNodesFromArrayOfStrings:(NSArray*) gedLines;

- (NSString *)gedcomString;
- (NSArray *)gedcomLines;
- (NSArray *)gedcomLinesAtLevel:(int) level;

-(GCNode *)subNodeForTag:(NSString *)tag;
-(NSArray *)subNodesForTag:(NSString *)tag;

-(GCNode *)subNodeForTagPath:(NSString *)tagPath; //tagPath can be for instance BIRT.DATE
-(NSArray *)subNodesForTagPath:(NSString *)tagPath;

@property (readonly) GCNode *parent;
@property (readonly) NSString *gedTag;
@property (readonly) NSString *gedValue;
@property (readonly) NSString *xref;
@property (readonly) NSString *lineSeparator;
@property (readonly) BOOL isCustomTag;
@property (readonly) NSArray *subNodes;

@end

