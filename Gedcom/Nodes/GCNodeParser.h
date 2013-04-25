//
//  GCNodeParser.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCNodeParserDelegate;

/**
 
 GCNodeParser parses the actual nodes.
 
 */
@interface GCNodeParser : NSObject

/// @name Obtaining nodes

/** Causes the receiver to parse a string of Gedcom data into GCNode objects. Delegates implement GCNodeParserDelegate to receive callbacks as the parse progresses.
 
 @param gedString A string containing Gedcom data.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return `YES` if the parse was successful. If the receiver was unable to parse the string, it will return `NO` and set the error pointer to an NSError describing the problem.
 */
- (BOOL)parseString:(NSString *)gedString error:(NSError **)error;

/// @name Setting a delegate

/// The delegate of the receiver.
@property (nonatomic, weak) id<GCNodeParserDelegate> delegate;

@end

@interface GCNodeParser (GCConvenienceMethods)

/// @name Obtaining nodes

/** Given a string of Gedcom data, will create an array of the nodes at level 0 of the data. Each node will further have subnodes as indicated by their level in the data.
 
 @param gedString A string of Gedcom data
 @return An array of nodes.
 */
+ (NSArray *)arrayOfNodesFromString:(NSString*)gedString;

@end