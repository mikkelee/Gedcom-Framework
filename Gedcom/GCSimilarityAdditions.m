//
//  GCSimilarityAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 25/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCSimilarityAdditions.h"

#import "GCAttribute.h"
#import "GCRelationship.h"
#import "GCValue_internal.h"

#import "GCTagAccessAdditions.h"

#import "NSString+JaroWinkler.h"

@implementation GCContext (GCSimilarityAdditions)

- (NSDictionary *)recordsSimilarTo:(GCRecord *)record
{
    return nil; //TODO
}

@end

static GCSimilarity threshold = 0.9f;

void similarity(GCObject *obj1, GCObject *obj2, GCSimilarity *sum, NSUInteger *count) {
    for (NSString *type in obj1.validPropertyTypes) {
        if ([obj1 allowsMultipleOccurrencesOfPropertyType:type]) {
            if ([[obj1 valueForKey:type] count] == 0) {
                for (GCProperty *prop2 in [obj2 valueForKey:type]) {
                    (*count)++;
                }
            } else {
                (*count)++;
                for (GCProperty *prop1 in [obj1 valueForKey:type]) {
                    BOOL foundSimilar = NO;
                    GCSimilarity tmpSum = 0.0f;
                    
                    for (GCProperty *prop2 in [obj2 valueForKey:type]) {
                        tmpSum = [prop1 similarityTo:prop2];
                        NSLog(@"tmpSum: %f", tmpSum);
                        if (tmpSum > threshold) {
                            foundSimilar = YES;
                        }
                    }
                    
                    if (foundSimilar) {
                        (*sum) += tmpSum;
                    }
                }
            }
        } else {
            (*count)++;
            if (([obj1 valueForKey:type] && ![obj2 valueForKey:type]) ||
                (![obj1 valueForKey:type] && [obj2 valueForKey:type])) {
                (*sum) += 0.0f;
            } else if (![obj1 valueForKey:type] && ![obj2 valueForKey:type]) {
                (*sum) += 1.0f;
            } else {
                (*sum) += [[obj1 valueForKey:type] similarityTo:[obj2 valueForKey:type]];
            }
        }
        
        NSLog(@"%@ :: %f / %ld = %f", type, *sum, *count, *sum / *count);
    }
}

@implementation GCRecord (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCRecord *)record
{
    return [self similarityTo:record traverseRelationships:YES];
}

- (GCSimilarity)similarityTo:(GCRecord *)record traverseRelationships:(BOOL)traverse
{
    if ([self class] != [record class]) {
        return 0.0f;
    }
    
    GCSimilarity sum = 0.0f;
    NSUInteger count = 0;
    
    similarity(self, record, &sum, &count);
    
    return sum/count;
}

@end

@implementation GCProperty (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCProperty *)property
{
    NSLog(@"You must override %@ in %@", NSStringFromSelector(_cmd), [self className]);
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

@end

@implementation GCAttribute (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCAttribute *)attribute
{
    if ([self class] != [attribute class]) {
        return 0.0f;
    }
    
    GCSimilarity sum = [self.value similarityTo:attribute.value];
    NSUInteger count = 1;
    
    similarity(self, attribute, &sum, &count);
    
    return sum/count;
}

@end

@implementation GCRelationship (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCRelationship *)relationship
{
    if ([self class] != [relationship class]) {
        return 0.0f;
    }
    
    GCSimilarity sum = [self.target similarityTo:relationship.target traverseRelationships:NO];
    NSUInteger count = 1;
    
    similarity(self, relationship, &sum, &count);
    
    return sum/count;
}

@end

@implementation GCValue (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCValue *)value
{
    NSLog(@"You must override %@ in %@", NSStringFromSelector(_cmd), [self className]);
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

@end

@implementation GCString (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCNamestring *)value
{
    if ([self class] != [value class]) {
        return 0.0f;
    }
    
    return [self.gedcomString jaroWinklerDistanceToString:value.gedcomString];
}

@end

@implementation GCGender (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCGender *)value
{
    if ([self class] != [value class]) {
        return 0.0f;
    }
    
    if (self == value) {
        return 1.0f;
    } else if (self == [GCGender unknownGender] || value == [GCGender unknownGender]) {
        return 0.5f;
    } else {
        return 0.0f;
    }
}

@end

@implementation GCBool (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCBool *)value
{
    if ([self class] != [value class]) {
        return 0.0f;
    }
    
    if (self == value) {
        return 1.0f;
    } else {
        return 0.0f;
    }
}

@end

@implementation GCDate (GCSimilarityAdditions)

- (GCSimilarity)similarityTo:(GCBool *)value
{
    if ([self class] != [value class]) {
        return 0.0f;
    }
    
    return 1.0f; //TODO
}

@end