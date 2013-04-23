//
//  GCPlacestring.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValue.h"

@interface GCPlacestring ()

@property GCPlacestring *superPlace;

@end

@implementation GCPlacestring {
}

__strong static GCPlacestring *_rootPlace = nil;
__strong static NSMutableDictionary *_allPlaces = nil;

+ (void)initialize
{
    _rootPlace = [[self alloc] initWithValue:@"@ROOT"];
    _allPlaces = [NSMutableDictionary dictionary];
}

+ (id)rootPlace
{
    return _rootPlace;
}

- (instancetype)initWithValue:(NSString *)value
{
    self = [super init];
    
    if (self) {
        _name = value;
        _subPlaces = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (id)valueWithGedcomString:(NSString *)gedcomString
{
    @synchronized(_allPlaces) {
        if (_allPlaces[gedcomString]) {
            return _allPlaces[gedcomString];
        }
    }
    
    @synchronized([self rootPlace]) {
        NSArray *places = [gedcomString componentsSeparatedByString:@","];
        
        GCPlacestring *parent = self.rootPlace;
        for (NSString *place in [places reverseObjectEnumerator]) {
            NSString *cleanPlace = [place stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (parent.subPlaces[cleanPlace]) {
                parent = parent.subPlaces[cleanPlace];
            } else {
                GCPlacestring *place = [[self alloc] initWithValue:cleanPlace];
                [parent addSubPlace:place];
                parent = place;
            }
        }
        
        _allPlaces[gedcomString] = parent;
        
        return parent;
    }
}

- (void)addSubPlace:(GCPlacestring *)subPlace
{
    [_subPlaces setValue:subPlace forKey:subPlace.gedcomString];
    subPlace.superPlace = self;
}

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [[self superPlace] compare:[other superPlace]];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    return [self.name localizedCaseInsensitiveCompare:[other name]];
}

- (NSString *)gedcomString
{
    NSMutableArray *placeComponents = [NSMutableArray arrayWithObject:self.name];
    
    GCPlacestring *place = self;
    while ((place = place.superPlace) && place != [[self class] rootPlace]) {
        [placeComponents addObject:place.name];
    }
    
    return [placeComponents componentsJoinedByString:@", "];
}

- (NSString *)displayString
{
    return self.gedcomString;
}

//COV_NF_START
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", [super description], self.subPlaces];
}
//COV_NF_END

@end
