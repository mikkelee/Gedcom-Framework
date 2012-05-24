//
//  GCPlacestring.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCPlacestring.h"

@interface GCPlacestring ()

@property GCPlacestring *superPlace;

@end

@implementation GCPlacestring {
    NSString *_name;
    NSMutableDictionary *_subPlaces;
}

static GCPlacestring *_rootPlace = nil;

- (id)initWithValue:(NSString *)value
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
    @synchronized(_rootPlace) {
        if (_rootPlace == nil) {
            _rootPlace = [[self alloc] initWithValue:@"@ROOT"];
        }
        
        NSArray *places = [gedcomString componentsSeparatedByString:@","];
        
        GCPlacestring *parent = _rootPlace;
        for (NSString *place in [places reverseObjectEnumerator]) {
            NSString *cleanPlace = [place stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([[parent subPlaces] objectForKey:cleanPlace]) {
                parent = [[parent subPlaces] objectForKey:cleanPlace];
            } else {
                GCPlacestring *place = [[self alloc] initWithValue:cleanPlace];
                [parent addSubPlace:place];
                parent = place;
            }
        }
        
        return parent;
    }
}

- (void)addSubPlace:(GCPlacestring *)subPlace
{
    [_subPlaces setValue:subPlace forKey:[subPlace gedcomString]];
    [subPlace setSuperPlace:self];
}

- (NSComparisonResult)compare:(id)other
{
    NSComparisonResult result = [[self superPlace] compare:[other superPlace]];
    
    if (result != NSOrderedSame) {
        return result;
    }
    
    return [[self name] localizedCaseInsensitiveCompare:[other name]];
}

- (NSString *)gedcomString
{
    NSMutableArray *placeComponents = [NSMutableArray arrayWithObject:[self name]];
    
    id place = self;
    while ((place = [place superPlace]) && place != _rootPlace) {
        [placeComponents addObject:[place name]];
    }
    
    return [placeComponents componentsJoinedByString:@", "];
}

- (NSString *)displayString
{
    return [self gedcomString];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@: %@)", [super description], [self name], [self subPlaces]];
}

@synthesize name = _name;

@synthesize superPlace = _superPlace;
@synthesize subPlaces = _subPlaces;

@end
