//
//  GCNodeParser.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCNodeParserDelegate;

@interface GCNodeParser : NSObject

+ (id)sharedParser;

- (BOOL)parseString:(NSString *)gedString error:(NSError **)error;

@property (weak) id<GCNodeParserDelegate> delegate;

@end

@interface GCNodeParser (GCConvenienceMethods)

/** Given a string of Gedcom data, will create an array of the nodes at level 0 of the data. Each node will further have subnodes as indicated by their level in the data.
 
 @param gedString A string of Gedcom data
 @return An array of nodes.
 */
+ (NSArray *)arrayOfNodesFromString:(NSString*)gedString;

@end