//
//  GCTag.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCTag.h"

@interface GCTag (Internals)

@property BOOL isCustom;

@end

@implementation GCTag {
    NSString *_tag;
}

__strong static id tagNames = nil;
__strong static id nameTags = nil;

-(void)setup
{
    //TODO cleaner!
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        tagNames = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"Abbreviation",@"ABBR",
                    @"Address",@"ADDR",
                    @"Adoption",@"ADOP",
                    @"Address1",@"ADR1",
                    @"Address2",@"ADR2",
                    @"Afn",@"AFN",
                    @"Age",@"AGE",
                    @"Agency",@"AGNC",
                    @"Alias",@"ALIA",
                    @"Ancestors",@"ANCE",
                    @"Ances Interest",@"ANCI",
                    @"Annulment",@"ANUL",
                    @"Associates",@"ASSO",
                    @"Author",@"AUTH",
                    @"Baptism-LDS",@"BAPL",
                    @"Baptism",@"BAPM",
                    @"Bar Mitzvah",@"BARM",
                    @"Bas Mitzvah",@"BASM",
                    @"Birth",@"BIRT",
                    @"Blessing",@"BLES",
                    @"Binary Object",@"BLOB",
                    @"Burial",@"BURI",
                    @"Call Number",@"CALN",
                    @"Caste",@"CAST",
                    @"Cause",@"CAUS",
                    @"Census",@"CENS",
                    @"Change",@"CHAN",
                    @"Character",@"CHAR",
                    @"Child",@"CHIL",
                    @"Christening",@"CHR",
                    @"Adult Christening",@"CHRA",
                    @"City",@"CITY",
                    @"Concatenation",@"CONC",
                    @"Confirmation",@"CONF",
                    @"Confirmation L",@"CONL",
                    @"Continued",@"CONT",
                    @"Copyright",@"COPR",
                    @"Corporate",@"CORP",
                    @"Cremation",@"CREM",
                    @"Country",@"CTRY",
                    @"Data",@"DATA",
                    @"Date",@"DATE",
                    @"Death",@"DEAT",
                    @"Descendants",@"DESC",
                    @"Descendant Int",@"DESI",
                    @"Destination",@"DEST",
                    @"Divorce",@"DIV",
                    @"Divorce Filed",@"DIVF",
                    @"Phy Description",@"DSCR",
                    @"Education",@"EDUC",
                    @"Emigration",@"EMIG",
                    @"Endowment",@"ENDL",
                    @"Engagement",@"ENGA",
                    @"Event",@"EVEN",
                    @"Family",@"FAM",
                    @"Family Child",@"FAMC",
                    @"Family File",@"FAMF",
                    @"Family Spouse",@"FAMS",
                    @"First Communion",@"FCOM",
                    @"File",@"FILE",
                    @"Format",@"FORM",
                    @"Gedcom",@"GEDC",
                    @"Given Name",@"GIVN",
                    @"Graduation",@"GRAD",
                    @"Header",@"HEAD",
                    @"Husband",@"HUSB",
                    @"Ident Number",@"IDNO",
                    @"Immigration",@"IMMI",
                    @"Individual",@"INDI",
                    @"Language",@"LANG",
                    @"Legatee",@"LEGA",
                    @"Marriage Bann",@"MARB",
                    @"Marr Contract",@"MARC",
                    @"Marr License",@"MARL",
                    @"Marriage",@"MARR",
                    @"Marr Settlement",@"MARS",
                    @"Media",@"MEDI",
                    @"Name",@"NAME",
                    @"Nationality",@"NATI",
                    @"Naturalization",@"NATU",
                    @"Children_count",@"NCHI",
                    @"Nickname",@"NICK",
                    @"Marriage_count",@"NMR",
                    @"Note",@"NOTE",
                    @"Name_prefix",@"NPFX",
                    @"Name_suffix",@"NSFX",
                    @"Object",@"OBJE",
                    @"Occupation",@"OCCU",
                    @"Ordinance",@"ORDI",
                    @"Ordination",@"ORDN",
                    @"Page",@"PAGE",
                    @"Pedigree",@"PEDI",
                    @"Phone",@"PHON",
                    @"Place",@"PLAC",
                    @"Postal_code",@"POST",
                    @"Probate",@"PROB",
                    @"Property",@"PROP",
                    @"Publication",@"PUBL",
                    @"Quality Of Data",@"QUAY",
                    @"Reference",@"REFN",
                    @"Relationship",@"RELA",
                    @"Religion",@"RELI",
                    @"Repository",@"REPO",
                    @"Residence",@"RESI",
                    @"Restriction",@"RESN",
                    @"Retirement",@"RETI",
                    @"Rec File Number",@"RFN",
                    @"Rec Id Number",@"RIN",
                    @"Role",@"ROLE",
                    @"Sex",@"SEX",
                    @"Sealing Child",@"SLGC",
                    @"Sealing Spouse",@"SLGS",
                    @"Source",@"SOUR",
                    @"Surn Prefix",@"SPFX",
                    @"Soc Sec Number",@"SSN",
                    @"State",@"STAE",
                    @"Status",@"STAT",
                    @"Submitter",@"SUBM",
                    @"Submission",@"SUBN",
                    @"Surname",@"SURN",
                    @"Temple",@"TEMP",
                    @"Text",@"TEXT",
                    @"Time",@"TIME",
                    @"Title",@"TITL",
                    @"Trailer",@"TRLR",
                    @"Type",@"TYPE",
                    @"Version",@"VERS",
                    @"Wife",@"WIFE",
                    @"Will",@"WILL",
                    nil];
        nameTags = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"ABBR",@"Abbreviation",
                    @"ADDR",@"Address",
                    @"ADOP",@"Adoption",
                    @"ADR1",@"Address1",
                    @"ADR2",@"Address2",
                    @"AFN",@"Afn",
                    @"AGE",@"Age",
                    @"AGNC",@"Agency",
                    @"ALIA",@"Alias",
                    @"ANCE",@"Ancestors",
                    @"ANCI",@"Ances Interest",
                    @"ANUL",@"Annulment",
                    @"ASSO",@"Associates",
                    @"AUTH",@"Author",
                    @"BAPL",@"Baptism-LDS",
                    @"BAPM",@"Baptism",
                    @"BARM",@"Bar Mitzvah",
                    @"BASM",@"Bas Mitzvah",
                    @"BIRT",@"Birth",
                    @"BLES",@"Blessing",
                    @"BLOB",@"Binary Object",
                    @"BURI",@"Burial",
                    @"CALN",@"Call Number",
                    @"CAST",@"Caste",
                    @"CAUS",@"Cause",
                    @"CENS",@"Census",
                    @"CHAN",@"Change",
                    @"CHAR",@"Character",
                    @"CHIL",@"Child",
                    @"CHR",@"Christening",
                    @"CHRA",@"Adult Christening",
                    @"CITY",@"City",
                    @"CONC",@"Concatenation",
                    @"CONF",@"Confirmation",
                    @"CONL",@"Confirmation L",
                    @"CONT",@"Continued",
                    @"COPR",@"Copyright",
                    @"CORP",@"Corporate",
                    @"CREM",@"Cremation",
                    @"CTRY",@"Country",
                    @"DATA",@"Data",
                    @"DATE",@"Date",
                    @"DEAT",@"Death",
                    @"DESC",@"Descendants",
                    @"DESI",@"Descendant Int",
                    @"DEST",@"Destination",
                    @"DIV",@"Divorce",
                    @"DIVF",@"Divorce Filed",
                    @"DSCR",@"Phy Description",
                    @"EDUC",@"Education",
                    @"EMIG",@"Emigration",
                    @"ENDL",@"Endowment",
                    @"ENGA",@"Engagement",
                    @"EVEN",@"Event",
                    @"FAM",@"Family",
                    @"FAMC",@"Family Child",
                    @"FAMF",@"Family File",
                    @"FAMS",@"Family Spouse",
                    @"FCOM",@"First Communion",
                    @"FILE",@"File",
                    @"FORM",@"Format",
                    @"GEDC",@"Gedcom",
                    @"GIVN",@"Given Name",
                    @"GRAD",@"Graduation",
                    @"HEAD",@"Header",
                    @"HUSB",@"Husband",
                    @"IDNO",@"Ident Number",
                    @"IMMI",@"Immigration",
                    @"INDI",@"Individual",
                    @"LANG",@"Language",
                    @"LEGA",@"Legatee",
                    @"MARB",@"Marriage Bann",
                    @"MARC",@"Marr Contract",
                    @"MARL",@"Marr License",
                    @"MARR",@"Marriage",
                    @"MARS",@"Marr Settlement",
                    @"MEDI",@"Media",
                    @"NAME",@"Name",
                    @"NATI",@"Nationality",
                    @"NATU",@"Naturalization",
                    @"NCHI",@"Children_count",
                    @"NICK",@"Nickname",
                    @"NMR",@"Marriage_count",
                    @"NOTE",@"Note",
                    @"NPFX",@"Name_prefix",
                    @"NSFX",@"Name_suffix",
                    @"OBJE",@"Object",
                    @"OCCU",@"Occupation",
                    @"ORDI",@"Ordinance",
                    @"ORDN",@"Ordination",
                    @"PAGE",@"Page",
                    @"PEDI",@"Pedigree",
                    @"PHON",@"Phone",
                    @"PLAC",@"Place",
                    @"POST",@"Postal_code",
                    @"PROB",@"Probate",
                    @"PROP",@"Property",
                    @"PUBL",@"Publication",
                    @"QUAY",@"Quality Of Data",
                    @"REFN",@"Reference",
                    @"RELA",@"Relationship",
                    @"RELI",@"Religion",
                    @"REPO",@"Repository",
                    @"RESI",@"Residence",
                    @"RESN",@"Restriction",
                    @"RETI",@"Retirement",
                    @"RFN",@"Rec File Number",
                    @"RIN",@"Rec Id Number",
                    @"ROLE",@"Role",
                    @"SEX",@"Sex",
                    @"SLGC",@"Sealing Child",
                    @"SLGS",@"Sealing Spouse",
                    @"SOUR",@"Source",
                    @"SPFX",@"Surn Prefix",
                    @"SSN",@"Soc Sec Number",
                    @"STAE",@"State",
                    @"STAT",@"Status",
                    @"SUBM",@"Submitter",
                    @"SUBN",@"Submission",
                    @"SURN",@"Surname",
                    @"TEMP",@"Temple",
                    @"TEXT",@"Text",
                    @"TIME",@"Time",
                    @"TITL",@"Title",
                    @"TRLR",@"Trailer",
                    @"TYPE",@"Type",
                    @"VERS",@"Version",
                    @"WIFE",@"Wife",
                    @"WILL",@"Will",
                    nil];
    });
}

-(id)initWithTag:(NSString *)tag
{
    self = [super init];
    
    if (self) {
        _tag = tag;
        
        [self setIsCustom:([tagNames valueForKey:tag] == nil)];
    }
    
    return self;
}

-(id)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self) {
        _tag = [nameTags valueForKey:name];
        
        [self setIsCustom:([nameTags valueForKey:name] == nil)];
    }
    
    return self;
}

- (NSString *)tag
{
    return _tag;
}

- (NSString *)name
{
    return [tagNames valueForKey:_tag];
}

@synthesize isCustom;

@end
