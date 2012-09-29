//
//  GCPredicateExtensions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCPredicateExtensions.h"

@implementation GCIndividualEntity (GCPredicateExtensions)

+ (NSArray *)defaultPredicateEditorRowTemplates
{
    // TODO obtain these from GCValue subclass...
    NSArray *stringOperators = @[
    @(NSContainsPredicateOperatorType),
    @(NSEqualToPredicateOperatorType),
    @(NSLessThanPredicateOperatorType),
    @(NSGreaterThanPredicateOperatorType)
    ];
    NSArray *dateOperators = @[
    @(NSEqualToPredicateOperatorType),
    @(NSBeginsWithPredicateOperatorType),
    @(NSEndsWithPredicateOperatorType)
    ];
    
    NSArray *stringExpressions = @[
    [NSExpression expressionForKeyPath:@"personalNames.value.gedcomString"],
    [NSExpression expressionForKeyPath:@"individualEvents.place.value.gedcomString"]
    ];
    
    NSArray *dateExpressions = @[
    [NSExpression expressionForKeyPath:@"births.date.value.minDate"]
    ];
    
    NSArray *compoundPredicateTypes = @[
    @(NSOrPredicateType),
    @(NSAndPredicateType),
    @(NSNotPredicateType),
    ];
    NSPredicateEditorRowTemplate *compoundPredicateRow = [[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:compoundPredicateTypes];
    
    return @[
    compoundPredicateRow,
    [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:stringExpressions
                                     rightExpressionAttributeType:NSStringAttributeType
                                                         modifier:NSAnyPredicateModifier
                                                        operators:stringOperators
                                                          options:0],
    [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:dateExpressions
                                     rightExpressionAttributeType:NSStringAttributeType
                                                         modifier:NSAnyPredicateModifier
                                                        operators:dateOperators
                                                          options:0]
    
    ];
    
    
}

@end
