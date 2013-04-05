//
//  GCNodeParserDelegate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 04/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCNodeParser;
@class GCNode;

@protocol GCNodeParserDelegate <NSObject>

@optional

/** Will be called each time a complete root GCNode has been parsed.
 
 @param parser The parser that sent the message.
 @param node The node that was parsed.
 */
- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node;

- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount;

@end
