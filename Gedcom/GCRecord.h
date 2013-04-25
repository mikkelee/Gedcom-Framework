//
//  GCRecord.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 21/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCEntity.h"

/**
 
 Records are objects such as an individual or a family.
 
 */
@interface GCRecord : GCEntity

#pragma mark Objective-C properties

/// @name Accessing properties

/// The xref of the receiver. Can and will change, so is not to be used as a permanent link.
/// @see GCUserReferenceNumberAttribute
/// @see GCRecordIdNumberAttribute
@property (nonatomic, readonly) NSString *xref;

/// A URL pointing to the object; can be used with GCXrefProtocol. URLs are not permanent, but are unique.
@property (nonatomic, readonly) NSURL *URL;

/// The last time the entity was modified. Will access the entity's GCChangeInfoAttribute to obtain the info. Note that every KVC-compliant change made to the entity will cause the change info to update.
@property (readonly, nonatomic) NSDate *modificationDate;

@end
