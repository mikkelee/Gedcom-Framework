//
//  GCMutableArrayProxy.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCMutableArrayProxy : NSObject

#pragma mark Initialization

- (id)initWithMutableArray:(NSMutableArray *)array addBlock:(void (^)(id obj))addBlock removeBlock:(void (^)(id obj))removeBlock;

//forwards all NSMutableArray-selectors to contained NSMutableArray, performs blocks when adding/removing objects.

@end
