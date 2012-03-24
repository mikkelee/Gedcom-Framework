//
//  GCInterpretedDate.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 17/02/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCAttributedDate.h"

@class GCDatePhrase;

@interface GCInterpretedDate : GCAttributedDate <NSCoding, NSCopying> {

}

@property (copy) GCDatePhrase *phrase;

@end
