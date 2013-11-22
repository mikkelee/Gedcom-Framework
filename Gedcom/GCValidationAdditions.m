//
//  GCValidationAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValidationAdditions.h"

#import "GedcomErrors.h"
#import "Gedcom_internal.h"

#import "GCContext+GCKeyValueAdditions.h"
#import "GCTagAccessAdditions.h"

#import "GCRecord.h"
#import "GCEntity.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCValue_internal.h"

NSString *GCErrorDomain = @"GCErrorDomain";

@implementation GCContext (GCValidationAdditions)

- (BOOL)validateContext:(NSError *__autoreleasing *)error
{
    BOOL isValid = YES;
    NSError *returnError = nil;
    
    if (self.header == nil) {
        isValid &= NO;
        
        NSString *errorString = GCLocalizedString(@"Context has no header.", @"Errors");
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: errorString,
                                   NSAffectedObjectsErrorKey: self
                                   };
        
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                     code:GCMissingHeaderError
                                                                 userInfo:userInfo]);
    }
    
    for (GCEntity *entity in self.mutableEntities) {
        //NSLog(@"validating %@", [self xrefForEntity:entity]);
        
        NSError *err = nil;
        
        isValid &= [entity validateObject:&err];
        
        if (err) {
            returnError = combineErrors(returnError, err);
        }
    }
    
    if (!isValid) {
        if (error != NULL) {
            *error = returnError;
        }
    }
    
    return isValid;
}

@end

@implementation GCObject (GCValidationMethods)

- (BOOL)validateObject:(NSError **)outError
{
    //NSLog(@"validating: %@", self);
    
    BOOL isValid = YES;
    
    NSError *returnError = nil;
    
    NSSet *propertyKeys = [self.validPropertyTypes set];
    
    for (NSString *propertyKey in propertyKeys) {
        NSInteger propertyCount = 0;
        
        if ([self allowsMultipleOccurrencesOfPropertyType:propertyKey]) {
            propertyCount = [[self valueForKey:propertyKey] count];
            
            for (id property in [self valueForKey:propertyKey]) {
                NSError *err = nil;
                
                BOOL propertyValid = [property validateObject:&err];
                
                if (!propertyValid) {
                    isValid &= NO;
                    returnError = combineErrors(returnError, err);
                }
            }
        } else {
            propertyCount = [self valueForKey:propertyKey] ? 1 : 0;
            
            if (propertyCount) {
                NSError *err = nil;
                
                BOOL propertyValid = [[self valueForKey:propertyKey] validateObject:&err];
                
                if (!propertyValid) {
                    isValid &= NO;
                    returnError = combineErrors(returnError, err);
                }
            }
        }
        
        GCAllowedOccurrences allowedOccurrences = [self allowedOccurrencesOfPropertyType:propertyKey];
        
        if (propertyCount > allowedOccurrences.max) {
            isValid &= NO;
            
            NSString *formatString = GCLocalizedString(@"Too many values for key %@ on %@", @"Errors");
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, propertyKey, self.type],
                                       NSAffectedObjectsErrorKey: self
                                       };
            
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                         code:GCTooManyValuesError
                                                                     userInfo:userInfo]);
        }
        
        if (propertyCount < allowedOccurrences.min) {
            isValid &= NO;
            
            NSString *formatString = GCLocalizedString(@"Too few values for key %@ on %@", @"Errors");
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, propertyKey, self.type],
                                       NSAffectedObjectsErrorKey: self
                                       };
            
            returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                         code:GCTooFewValuesError
                                                                     userInfo:userInfo]);
        }
    }
    
    if (!isValid && outError != NULL) {
        *outError = returnError;
    }
    
    return isValid;
}

@end

@implementation GCAttribute (GCValidationMethods)

- (BOOL)validateObject:(NSError **)outError
{
    BOOL isValid = YES;
    
    NSError *returnError = nil;
    
    NSError *err = nil;
    
    BOOL superValid = [super validateObject:&err];
    
    if (!superValid) {
        isValid &= NO;
        returnError = combineErrors(returnError, err);
    }
    
    returnError = combineErrors(returnError, err);
    
    if (self.valueType) {
        if (self.value) {
            if (![self.value isKindOfClass:self.valueType]) {
                NSString *formatString = GCLocalizedString(@"Value %@ is incorrect type for %@ (should be %@)", @"Errors");
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.value, self.type, self.valueType],
                                           NSAffectedObjectsErrorKey: self
                                           };
                
                returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                             code:GCIncorrectValueTypeError
                                                                         userInfo:userInfo]);
                isValid &= NO;
            } else if ([self.allowedValues count] > 0 && ![self.value _isContainedInArray:self.allowedValues]) {
                NSString *formatString = GCLocalizedString(@"Value %@ is not allowed for %@ (should be one of %@)", @"Errors");
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.value, self.type, self.allowedValues],
                                           NSAffectedObjectsErrorKey: self
                                           };
                
                returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                             code:GCIncorrectValueTypeError
                                                                         userInfo:userInfo]);
                isValid &= NO;
            }
        } else {
            if (!self.allowsNilValue) {
                NSString *formatString = GCLocalizedString(@"Value is missing for %@ (should be a %@)", @"Errors");
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString,  self.type, self.valueType],
                                           NSAffectedObjectsErrorKey: self
                                           };
                
                returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                             code:GCValueMissingError
                                                                         userInfo:userInfo]);
                isValid &= NO;
            }
        }
    }
    
    if (!isValid) {
        *outError = returnError;
    }
    
    return isValid;
}

@end

@implementation GCRelationship (GCValidationMethods)

- (BOOL)validateObject:(NSError **)outError
{
    BOOL isValid = YES;
    
    NSError *returnError = nil;
    
    NSError *err = nil;
    
    BOOL superValid = [super validateObject:&err];
    
    if (!superValid) {
        isValid &= NO;
        returnError = combineErrors(returnError, err);
    }
    
    if (self.target == nil) {
        NSString *formatString = GCLocalizedString(@"Target is missing for %@ (should be a %@)", @"Errors");
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.type, self.targetType],
                                   NSAffectedObjectsErrorKey: self
                                   };
        
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                     code:GCTargetMissingError
                                                                 userInfo:userInfo]);
        isValid &= NO;
    } else if (![self.target isKindOfClass:self.targetType]) {
        NSString *formatString = GCLocalizedString(@"Target %@ is incorrect type for %@ (should be %@)", @"Errors");
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.target, self.type, self.targetType],
                                   NSAffectedObjectsErrorKey: self
                                   };
        
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                     code:GCIncorrectTargetTypeError
                                                                 userInfo:userInfo]);
        isValid &= NO;
    }
    
    if (!isValid) {
        *outError = returnError;
    }
    
    return isValid;
}

@end
