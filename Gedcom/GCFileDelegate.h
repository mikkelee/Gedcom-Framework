//
//  GCFileDelegate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 13/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GCFileDelegate)

- (void)file:(GCFile *)file updatedEntityCount:(int)entityCount;
- (void)file:(GCFile *)file didFinishWithEntityCount:(int)entityCount;

@end
