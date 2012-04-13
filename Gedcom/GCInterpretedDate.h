//
//  GCInterpretedDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCAttributedDate.h"

@class GCDatePhrase;

@interface GCInterpretedDate : GCAttributedDate

@property (copy) GCDatePhrase *datePhrase;

@end
