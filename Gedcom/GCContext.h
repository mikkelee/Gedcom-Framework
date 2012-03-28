//
//  GCXRefStore.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCEntity;

@interface GCContext : NSObject

+ (id)context;

- (NSString *)xrefForEntity:(GCEntity *)obj;
- (GCEntity *)entityForXref:(NSString *)xref;

//used by gedcom import:
- (void)storeXref:(NSString *)xref forEntity:(GCEntity *)obj;

@end
