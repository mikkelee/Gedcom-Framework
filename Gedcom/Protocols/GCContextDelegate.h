//
//  GCContextDelegate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCContext;
@class GCEntity;
@class GCNode;
@class GCTag;
@class GCObject;

/**
 
 A set of optional methods that can be implemented by a delegate.
 
 If a GCContext has a delegate, it will call these if they are implemented.
 
 */
@protocol GCContextDelegate <NSObject>

@optional

/** Will be called by the context if an entity was activated, for instance through the GCXrefProtocol.
 
 @param context The context that sent the message. 
 @param entity The entity.
 */
- (void)context:(GCContext *)context didReceiveActionForRecord:(GCEntity *)entity;

/** Will be called when a custom tag is encountered in a context.
 
 The delegate can choose to use the information contained in the node to alter the object, for instance the non-standard tag FAM._UMR could be used to add a note to the family entity that they were unmarried.
 
 @param context The context that sent the message.
 @param tag The unknown tag.
 @param node The complete node including value and subnodes.
 @param object The object the node was intended for.
 @return `YES` if the context should handle the tag itself, `NO` if the delegate handles it.
 */
- (BOOL)context:(GCContext *)context shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object;

/** Will be called just before a GCContext starts parsing nodes into entities.
 
 @param context The context that sent the message.
 @param nodeCount The number of nodes the context will parse.
 */
- (void)context:(GCContext *)context willParseNodes:(NSUInteger)nodeCount;

/** Will be called when a GCContext's entity count changes (either during parsing or general usage).
 
 @param context The context that sent the message.
 @param entityCount The number of entities currently in the context.
 */
- (void)context:(GCContext *)context didUpdateEntityCount:(NSUInteger)entityCount;

/** Will be called when a GCContext is done parsing.
 
 @param context The context that sent the message.
 @param entityCount The number of entities currently in the context.
 */
- (void)context:(GCContext *)context didParseNodesWithEntityCount:(NSUInteger)entityCount;

@end
