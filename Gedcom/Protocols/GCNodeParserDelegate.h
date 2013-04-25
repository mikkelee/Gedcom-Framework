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

/**
 
 A set of optional methods that can be implemented by a delegate.
 
 If a GCNodeParser has a delegate, it will call these if they are implemented.
 
 */
@protocol GCNodeParserDelegate <NSObject>

@optional

/** Will be called just before parsing starts.
 
 @param parser The parser that sent the message.
 @param characterCount The number of characters the parser intends to parse.
 */
- (void)parser:(GCNodeParser *)parser willParseCharacterCount:(NSUInteger)characterCount;

/** Will be called each time a complete root GCNode has been parsed.
 
 @param parser The parser that sent the message.
 @param node The node that was parsed.
 */
- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node;

/** Will be called when the parse has finished.
 
 @param parser The parser that sent the message.
 @param nodeCount The number of nodes that were parsed.
 */
- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount;

@end
