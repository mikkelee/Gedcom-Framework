//
//  GCSimpleAge.h
//  GCCoreData copy
//
//  Created by Mikkel Eide Eriksen on 08/06/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCAge.h"

@interface GCSimpleAge : GCAge {
    
}

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (NSComparisonResult)compare:(id)other;

@property (copy) NSDateComponents *ageComponents;

@end
