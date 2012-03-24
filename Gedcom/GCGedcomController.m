//
//  GedcomController.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGedcomController.h"

@implementation GCGedcomController

+ (id)sharedController // fancy new ARC/GCD singleton!
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
        
        if (_sharedInstance) {
            NSString *plistPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"tags" ofType:@"plist"];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:plistPath];
            [_sharedInstance setTags:[NSPropertyListSerialization propertyListFromData:data 
                                                                      mutabilityOption:0 
                                                                                format:NULL 
                                                                      errorDescription:nil]];
            //NSLog(@"tags: %@", [_sharedInstance tags]);
        }
    });
    
    return _sharedInstance;
}

@synthesize tags;

@end
