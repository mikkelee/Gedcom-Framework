//
//  GCList.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Gedcom/Gedcom.h>

@interface GCList : GCValue

- (id)initWithElements:(NSArray *)elements;

@property (readonly) NSArray *elements;

@end
