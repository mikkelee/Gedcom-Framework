//
//  GCName.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

@implementation GCNamestring {
    NSString *_cachedDisplayString;
}

- (NSComparisonResult)compare:(GCNamestring *)other
{
    return [self.displayString localizedCaseInsensitiveCompare:other.displayString];
}

- (NSString *)displayString
{
    if (!_cachedDisplayString) {
        NSArray *nameParts = [super.displayString componentsSeparatedByString:@"/"];
        
        switch ([nameParts count]) {
            case 1: // - no surname, "Jens"
                _cachedDisplayString = [NSString stringWithFormat:@", %@", nameParts[0]];
                break;
                
            case 3: // - surname, "Jens /Hansen/ Smed"
            {
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                
                NSString *suffix = ![[nameParts[2] stringByTrimmingCharactersInSet:whitespace] isEqualToString:@""] ? [NSString stringWithFormat:@" (%@)", [nameParts[2] stringByTrimmingCharactersInSet:whitespace]] : @"";
                
                _cachedDisplayString = [NSString stringWithFormat:@"%@, %@%@", 
                                        [nameParts[1] stringByTrimmingCharactersInSet:whitespace],
                                        [nameParts[0] stringByTrimmingCharactersInSet:whitespace],
                                        suffix
                                        ];
                break;
            }
                
            default:
                _cachedDisplayString = super.displayString;
                break;
        }
    }
    
    return _cachedDisplayString;
}

@end
