//
//  GCQualifiedAge.h
//  GCCoreData copy
//
//  Created by Mikkel Eide Eriksen on 13/06/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCAge.h"

@interface GCQualifiedAge : GCAge {
    
}

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (NSComparisonResult)compare:(id)other;

@property (copy) GCAge * age;
@property (assign) GCAgeQualifier qualifier;

@end
