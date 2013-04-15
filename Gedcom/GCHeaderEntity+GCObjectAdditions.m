//
//  GCHeaderEntity+GCObjectAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeaderEntity+GCObjectAdditions.h"

#import "GCContext.h"

#import "GCCharacterSetAttribute.h"
#import "GCHeaderSourceAttribute.h"
#import "GCDescriptiveNameAttribute.h"
#import "GCGedcomAttribute.h"
#import "GCVersionAttribute.h"
#import "GCGedcomFormatAttribute.h"
#import "GCSubmitterEntity.h"
#import "GCSubmitterReferenceRelationship.h"

@implementation GCHeaderEntity (GCObjectAdditions)

+ (id)defaultHeaderInContext:(GCContext *)context
{
    GCHeaderEntity *head = [GCHeaderEntity headerInContext:context];
    
    head.characterSet = [GCCharacterSetAttribute characterSetWithGedcomStringValue:@"UNICODE"];
    
    head.headerSource = [GCHeaderSourceAttribute headerSourceWithGedcomStringValue:@"Gedcom.framework"];
    head.headerSource.descriptiveName = [GCDescriptiveNameAttribute descriptiveNameWithGedcomStringValue:@"Gedcom.framework"];
    head.headerSource.version = [GCVersionAttribute versionWithGedcomStringValue:@"0.9.1"];
    
    head.gedcom = [GCGedcomAttribute gedcom];
    head.gedcom.version = [GCVersionAttribute versionWithGedcomStringValue:@"5.5"];
    head.gedcom.gedcomFormat = [GCGedcomFormatAttribute gedcomFormatWithGedcomStringValue:@"LINEAGE-LINKED"];
    
    GCSubmitterEntity *subm = [GCSubmitterEntity submitterInContext:context];
    subm.descriptiveName = [GCDescriptiveNameAttribute descriptiveNameWithGedcomStringValue:NSFullUserName()];
    
    head.submitterReference = [GCSubmitterReferenceRelationship submitterReference];
    head.submitterReference.target = subm;
    
    return head;
}

@end
