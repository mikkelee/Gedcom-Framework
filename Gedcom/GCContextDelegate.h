//
//  NSObject+GCContextDelegate.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCContext.h"

@class GCEntity;

@interface NSObject (GCContextDelegate)

- (void)context:(GCContext *)context didReceiveActionForEntity:(GCEntity *)entity;

@end
