//
//  GCValidationAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 15/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCValidationAdditions.h"

#import "GCContext+GCKeyValueAdditions.h"

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
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (self.header == nil) {
        isValid &= NO;
        
        NSString *errorString = [frameworkBundle localizedStringForKey:@"Context has no header"
                                                                 value:@"Context has no header"
                                                                 table:@"Errors"];
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
        *error = returnError;
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
    /*
     @synchronized (_propertyStore) {
     propertyKeys = [[NSSet setWithArray:[_propertyStore allKeys]] setByAddingObjectsFromSet:[self.validPropertyTypes set]];
     }*/
    
    for (NSString *propertyKey in propertyKeys) {
        GCTag *subTag = [GCTag tagNamed:propertyKey];
        
        NSInteger propertyCount = 0;
        
        if ([self _allowsMultipleOccurrencesOfPropertyType:propertyKey]) {
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
        
        GCAllowedOccurrences allowedOccurrences = [self.gedTag allowedOccurrencesOfSubTag:subTag];
        
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        
        if (propertyCount > allowedOccurrences.max) {
            isValid &= NO;
            
            NSString *formatString = [frameworkBundle localizedStringForKey:@"Too many values for key %@ on %@"
                                                                      value:@"Too many values for key %@ on %@"
                                                                      table:@"Errors"];
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
            
            NSString *formatString = [frameworkBundle localizedStringForKey:@"Too few values for key %@ on %@"
                                                                      value:@"Too few values for key %@ on %@"
                                                                      table:@"Errors"];
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
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (self.gedTag.valueType) {
        if (self.value) {
            if (![self.value isKindOfClass:self.gedTag.valueType]) {
                NSString *formatString = [frameworkBundle localizedStringForKey:@"Value %@ is incorrect type for %@ (should be %@)"
                                                                          value:@"Value %@ is incorrect type for %@ (should be %@)"
                                                                          table:@"Errors"];
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.value, self.type, self.gedTag.valueType],
                                           NSAffectedObjectsErrorKey: self
                                           };
                
                returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                             code:GCIncorrectValueTypeError
                                                                         userInfo:userInfo]);
                isValid &= NO;
            } else if ([self.gedTag.allowedValues count] > 0 && ![self.value _isContainedInArray:self.gedTag.allowedValues]) {
                NSString *formatString = [frameworkBundle localizedStringForKey:@"Value %@ is not allowed for %@ (should be one of %@)"
                                                                          value:@"Value %@ is not allowed for %@ (should be one of %@)"
                                                                          table:@"Errors"];
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.value, self.type, self.gedTag.allowedValues],
                                           NSAffectedObjectsErrorKey: self
                                           };
                
                returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                             code:GCIncorrectValueTypeError
                                                                         userInfo:userInfo]);
                isValid &= NO;
            }
        } else {
            if (!self.gedTag.allowsNilValue) {
                NSString *formatString = [frameworkBundle localizedStringForKey:@"Value is missing for %@ (should be a %@)"
                                                                          value:@"Value is missing for %@ (should be a %@)"
                                                                          table:@"Errors"];
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString,  self.type, self.gedTag.valueType],
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
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (self.target == nil) {
        NSString *formatString = [frameworkBundle localizedStringForKey:@"Target is missing for key %@ (should be a %@)"
                                                                  value:@"Target is missing for key %@ (should be a %@)"
                                                                  table:@"Errors"];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.type, self.gedTag.targetType],
                                   NSAffectedObjectsErrorKey: self
                                   };
        
        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                     code:GCTargetMissingError
                                                                 userInfo:userInfo]);
        isValid &= NO;
    } else if (![self.target isKindOfClass:self.gedTag.targetType]) {
        NSString *formatString = [frameworkBundle localizedStringForKey:@"Target %@ is incorrect type for key %@ (should be %@)"
                                                                  value:@"Target %@ is incorrect type for key %@ (should be %@)"
                                                                  table:@"Errors"];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:formatString, self.target, self.type, self.gedTag.targetType],
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
