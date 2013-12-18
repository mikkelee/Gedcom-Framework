//
//  GCHeaderEntity+GCObjectAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCHeaderEntity+GCObjectAdditions.h"

#import "GCContext_internal.h"

#import "GCCharacterSetAttribute.h"
#import "GCHeaderSourceAttribute.h"
#import "GCDescriptiveNameAttribute.h"
#import "GCGedcomAttribute.h"
#import "GCVersionAttribute.h"
#import "GCCorporationAttribute.h"
#import "GCAddressAttribute.h"
#import "GCGedcomFormatAttribute.h"
#import "GCSubmitterRecord.h"
#import "GCSubmitterReferenceRelationship.h"

@implementation GCHeaderEntity (GCObjectAdditions)

+ (instancetype)defaultHeaderInContext:(GCContext *)context
{
    NSDictionary *info = [[NSBundle bundleForClass:[self class]] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    
    GCHeaderEntity *head = [GCHeaderEntity headerInContext:context];
    
    head.characterSet = [GCCharacterSetAttribute characterSetWithGedcomStringValue:@"UNICODE"];
    
    head.headerSource = [GCHeaderSourceAttribute headerSourceWithGedcomStringValue:@"Gedcom.framework"];
    head.headerSource.descriptiveName = [GCDescriptiveNameAttribute descriptiveNameWithGedcomStringValue:@"Gedcom.framework"];
    head.headerSource.version = [GCVersionAttribute versionWithGedcomStringValue:version];
    head.headerSource.corporation = [GCCorporationAttribute corporationWithGedcomStringValue:@"Mikkel Eide Eriksen"];
    head.headerSource.corporation.address = [GCAddressAttribute addressWithGedcomStringValue:@"http://github.com/mikkelee/Gedcom-Framework"];
    
    head.gedcom = [GCGedcomAttribute gedcom];
    head.gedcom.version = [GCVersionAttribute versionWithGedcomStringValue:@"5.5"];
    head.gedcom.gedcomFormat = [GCGedcomFormatAttribute gedcomFormatWithGedcomStringValue:@"LINEAGE-LINKED"];
    
    //TODO check if context has submitter & use that?
    GCSubmitterRecord *subm = [GCSubmitterRecord submitterInContext:context];
    subm.descriptiveName = [GCDescriptiveNameAttribute descriptiveNameWithGedcomStringValue:NSFullUserName()];
    
    head.submitterReference = [GCSubmitterReferenceRelationship submitterReference];
    head.submitterReference.target = (GCRecord *)subm;
    
    return head;
}

@end
