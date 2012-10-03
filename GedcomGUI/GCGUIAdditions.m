//
//  GCGUIAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGUIAdditions.h"

@implementation GCObject (GCGUIAdditions)

+ (NSArray *)defaultPredicateEditorRowTemplates
{
    return nil; // no default for objects
}

+ (NSPredicateEditorRowTemplate *)defaultCompoundPredicateEditorRowTemplate
{
    NSArray *compoundPredicateTypes = @[
    @(NSOrPredicateType),
    @(NSAndPredicateType),
    @(NSNotPredicateType),
    ];
    
    return [[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:compoundPredicateTypes];
}

@end

@implementation GCValue (GCGUIAdditions)

+ (NSArray *)defaultPredicateOperators
{
    return @[
    @(NSContainsPredicateOperatorType),
    @(NSEqualToPredicateOperatorType),
    @(NSBeginsWithPredicateOperatorType),
    @(NSEndsWithPredicateOperatorType)
    ];
}

- (NSAttributeType)defaultAttributeType
{
    return NSStringAttributeType;
}

@end

@implementation GCDate (GCGUIAdditions)

+ (NSArray *)defaultPredicateOperators
{
    return @[
    @(NSEqualToPredicateOperatorType),
    @(NSLessThanPredicateOperatorType),
    @(NSGreaterThanPredicateOperatorType)
    ];
}

- (NSAttributeType)defaultAttributeType
{
    return NSDateAttributeType;
}

@end

@implementation GCBool (GCGUIAdditions)

+ (NSArray *)defaultPredicateOperators
{
    return @[
    @(NSEqualToPredicateOperatorType),
    @(NSNotEqualToPredicateOperatorType)
    ];
}

+ (NSAttributeType)defaultAttributeType
{
    return NSBooleanAttributeType;
}

+ (NSArray *)expressions
{
    return @[
    [NSExpression expressionForConstantValue:[self yes]],
    [NSExpression expressionForConstantValue:[self undecided]],
    ];
}

@end

@implementation GCGender (GCGUIAdditions)

+ (NSArray *)defaultPredicateOperators
{
    return @[
    @(NSEqualToPredicateOperatorType),
    @(NSNotEqualToPredicateOperatorType)
    ];
}

+ (NSAttributeType)defaultAttributeType
{
    return NSObjectIDAttributeType;
}

+ (NSArray *)expressions
{
    return @[
    [NSExpression expressionForConstantValue:[self maleGender]],
    [NSExpression expressionForConstantValue:[self femaleGender]],
    [NSExpression expressionForConstantValue:[self unknownGender]]
    ];
}

@end

@implementation GCIndividualEntity (GCGUIAdditions)

+ (NSArray *)defaultPredicateEditorRowTemplates
{
    NSArray *stringExpressions = @[
    [NSExpression expressionForKeyPath:@"personalNames.value.gedcomString"],
    [NSExpression expressionForKeyPath:@"individualEvents.place.value.gedcomString"]
    ];
    
    NSArray *dateExpressions = @[
    [NSExpression expressionForKeyPath:@"births.date.value"]
    ];
    
    
    return @[
    [self defaultCompoundPredicateEditorRowTemplate],
    [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[ [NSExpression expressionForKeyPath:@"sex.value"] ]
                                                 rightExpressions:[GCGender expressions]
                                                         modifier:NSDirectPredicateModifier
                                                        operators:[GCGender defaultPredicateOperators]
                                                          options:0],
    [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:stringExpressions
                                     rightExpressionAttributeType:NSStringAttributeType
                                                         modifier:NSAnyPredicateModifier
                                                        operators:[GCString defaultPredicateOperators]
                                                          options:0],
    [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:dateExpressions
                                     rightExpressionAttributeType:NSDateAttributeType
                                                         modifier:NSAnyPredicateModifier
                                                        operators:[GCDate defaultPredicateOperators]
                                                          options:0]
    
    ];
    
    
}

@end
