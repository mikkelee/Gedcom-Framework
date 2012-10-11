//
//  GCObject+GCSanityCheckAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 11/10/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject+GCSanityCheckAdditions.h"
#import "ValidationHelpers.h"

@implementation GCIndividualEntity (GCSanityCheckAdditions)

- (BOOL)sanityCheck:(NSError **)outError
{
	__block BOOL isSane = YES;
    __block NSError *returnError = nil;
	
	NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sanity"
                                                                          ofType:@"json"];
	NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:jsonPath];
	
    NSError *err = nil;
    
    NSDictionary *sanity = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:kNilOptions
                                                             error:&err];
    
    NSAssert(sanity != nil, @"error: %@", err);
    
	id settings = sanity[self.type];
    
	[settings[@"orderRequirements"] enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *eventsThatMustOccurLater, BOOL *stop){
		NSString *keyPath = [NSString stringWithFormat:@"%@s.date.value", key];
		for (GCDate *eventDate in [self valueForKeyPath:keyPath]) {
			for (id eventType in eventsThatMustOccurLater) {
				NSString *otherKeyPath = [NSString stringWithFormat:@"%@s.date.value", eventType];
				for (GCDate *otherEventDate in [self valueForKeyPath:otherKeyPath]) {
                    //NSLog(@"comparing %@ : %@ :: %@ : %@", key, eventType, eventDate, otherEventDate);
					if ([otherEventDate isLessThan:eventDate]) {
						isSane &= NO;
                        returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                                     code:GCSanityCheckInconsistency
                                                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ usually occurs before %@", key, eventType], NSAffectedObjectsErrorKey: self}]);
					}
				}
			}
		}
	}];
	
	[settings[@"ageRequirements"] enumerateKeysAndObjectsUsingBlock:^(id key, NSNumber *requiredAge, BOOL *stop){
		NSString *keyPath = [NSString stringWithFormat:@"%@s.age.value", key];
		for (GCAge *ageAtEvent in [self valueForKeyPath:keyPath]) {
			if ([ageAtEvent isLessThan:requiredAge]) {
				isSane &= NO;
                returnError = combineErrors(returnError, [NSError errorWithDomain:GCErrorDomain
                                                                             code:GCSanityCheckInconsistency
                                                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ is young for %@", ageAtEvent, key], NSAffectedObjectsErrorKey: self}]);
			}
		}
	}];
	
    if (!isSane) {
        *outError = returnError;
    }
    
	return isSane;
}

@end
