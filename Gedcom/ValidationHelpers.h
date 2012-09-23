//
//  ValidationHelpers.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/09/12.
//  Copyright 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline NSError * combineErrors(NSError *originalError, NSError *secondError) {
    if (!originalError) {
        return secondError;
    } else if (!secondError) {
        return originalError;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];
    
    if ([originalError code] == NSValidationMultipleErrorsError) {
        
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    } else {
        [errors addObject:originalError];
    }
    
    [userInfo setObject:errors forKey:NSDetailedErrorsKey];
    
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError
                           userInfo:userInfo];
}