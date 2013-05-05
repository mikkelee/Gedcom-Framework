# README #

**Note**: Functionality is basically all there, but API is not frozen yet, so be careful if you use it, and let me know if certain methods are needed.

A number of classes to ease [GEDCOM 5.5](http://www.gedcom.net/0g/gedcom55/)-manipulation in Cocoa through layers of abstraction. The intent is to hide the GEDCOM specifics, but to allow access if required.

A short summary of the functionality follows:

* GEDCOM is parsed and serialized in layers: text <=> GCNode <=> GCObject.
* Closest to the metal are GCNodes (parsed via GCNodeParser), a simple representation of the nested structure of GEDCOM text data with accessors for tag/value/xref/etc.
* Above GCNodes are GCObjects, which allow for more abstracted data access. There are two basic types of GCObject:
    - GCEntity: Root level entities - HEAD, TRLR, etc.
        * GCRecord: Root level records with xrefs - INDI, FAM, etc.
    - GCProperty: Objects can have a number of properties of which there are two kinds:
        * GCAttribute: Any node that describes an object - NAME, DATE, PLAC, etc.
        * GCRelationship: Any node that references other entities - FAMC, HUSB, ASSO, etc.
* These are then further subclassed as for instance GCIndividualRecord, GCSpouseInFamilyRelationship, etc, providing accessors to their properties.
* Translation between GCNodes and GCObjects is facilitated by GCTags which map between object types and tag codes, as well as know what subtags are valid, what type a value is, whether it's an entity or a property, etc.
* Attribute values are handled via subclasses of GCValue, which can be one of several types (like NSValue). Sorting (via compare:) and NSFormatters are provided. The types are:
    - GCGender
    - GCAge (class cluster, parsed via a [Ragel](http://www.complang.org/ragel/) state machine)
    - GCDate (class cluster, parsed via a Ragel state machine)
    - GCList
    - GCString
    - GCNamestring
    - GCPlacestring
    - GCNumber
    - GCBool
* Relationship integrity is handled with a GCContext (equivalent to a file) that ensures that all GCEntities have an internal 1-to-1 mapping with an xref, used for serializing from/to GEDCOM.
* Objects and contexts can be validated and will return detailed NSErrors.
* Full [AppleDoc](http://gentlebytes.com/appledoc/) documentation is contained in the headers and can be built with the Documentation target.
* No external dependencies for usage; compiling requires python & ragel.

Additionally two application targets are included:

* **GedcomTools**: A simple validation app that will display any validation errors it may find in a given Gedcom file. It will also sanity check a file for inconsistent attributes such as deaths occuring before births, etc.

* **GedcomGUI**: A simple GUI is included that can open a .ged file; it will display a list of the individuals with names and birth data, and allow the user to inspect the structures as gedcom strings as well as a hierarchy of display-formatted strings, as well as experiment with editing the Gedcom data directly, and see how it is parsed. Saving is not currently enabled to prevent accidental data loss. [Screenshot as of May 31, 2012](https://github.com/mikkelee/Gedcom-Framework/raw/master/screenshot.png)

# Version history #

```
0 HEAD
1 SOUR Gedcom.framework
2 VERS 0.9.4
2 NAME Gedcom.framework
2 CORP Mikkel Eide Eriksen
3 ADDR http://github.com/mikkelee/Gedcom-Framework
```

* 0.9.4 — Speed improvements. Loads my sample file in less than 2 seconds (down from 40 seconds in early dev).
* 0.9.3 — Refactor, speed improvements. Counting down to API freeze.
* 0.9.2 — BLOB decoding functional.
* 0.9.1 — all info in TGC55.ged can be losslessly handled, though it will not pass validation due to non-standard tags.
* 0.9.0 — Functionality is there; 1.0 comes after a bit more thorough testing/bugsquashing + documentation.

# TODO #

The most important remaining issues, loosely prioritized in order of importance:

* **tags.json**: 95% done (documentation is missing).
* **Docs**: Code samples in headers (see GCContext.h for preliminary example).
* **Unit tests**: Full code coverage.
* **Assertions**: Clean up; either remove, make full blown exceptions, or leave as-is with comment that it's for dev purposes.

Additionally there are at times a few minor TODOs scattered around the source files.

# Examples #

Showing some different ways to add attributes to an object:

``` objective-c
    // Create a context.
	GCContext *ctx = [GCContext context];
	
    // Create an individual entity in the context.
    GCIndividualRecord *indi = [GCIndividualRecord individualInContext:ctx];
    
    // Create an array of names and add them to the individual under "personalNames".
    [indi addAttributeWithType:@"personalNames" values:
     [GCNamestring valueWithGedcomString:@"Jens /Hansen/"],
     [GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"],
     nil];
    
    // Create a birth attribute, give it a date attribute and add it to the individual.
	GCBirthAttribute *birt = [GCBirthAttribute birth];
    
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    
    [indi.mutableProperties addObject:birt];
    
    [indi addAttributeWithType:@"deaths" value:[GCBool yes]];
```

The above is equivalent to the following GCNode:

``` objective-c
    GCNode *node = [GCNode nodeWithTag:@"INDI"
                                  xref:@"@INDI1@"
                              subNodes:@[
                                        [GCNode nodeWithTag:@"NAME"
                                                      value:@"Jens /Hansen/"],
                                        [GCNode nodeWithTag:@"NAME"
                                                      value:@"Jens /Hansen/ Smed"],
                                        [GCNode nodeWithTag:@"BIRT"
                                                      value:nil
                                                   subNodes:@[ [GCNode nodeWithTag:@"DATE"
                                                                             value:@"1 JAN 1901"] ]],
                                        [GCNode nodeWithTag:@"DEAT" 
                                                      value:@"Y"],
                                        ]];
```

And both are equivalent to the following Gedcom string:

```
0 @INDI1@ INDI
1 NAME Jens /Hansen/
1 NAME Jens /Hansen/ Smed
1 BIRT
2 DATE 1 JAN 1901
1 DEAT Y
```

Similarly, for relationships, the following:

```objective-c
	GCContext *ctx = [GCContext context];
	
	GCIndividualRecord *husb = [GCIndividualRecord individualInContext:ctx];
	[husb addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[husb addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
	GCIndividualRecord *wife = [GCIndividualRecord individualInContext:ctx];
	[wife addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Anne /Larsdatter/"]];
	[wife addAttributeWithType:@"sex" value:[GCGender femaleGender]];
	
	GCIndividualRecord *chil = [GCIndividualRecord individualInContext:ctx];
	[chil addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Hans /Jensen/"]];
	[chil addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
    GCFamilyRecord *fam = [GCFamilyRecord familyInContext:ctx];
    
	[fam addRelationshipWithType:@"husband" target:husb];
	[fam addRelationshipWithType:@"wife" target:wife];
	[fam addRelationshipWithType:@"child" target:chil];
    
    // alternately:
	// [husb addRelationshipWithType:@"spouseInFamily" target:fam];
	// [wife addRelationshipWithType:@"spouseInFamily" target:fam];
	// [chil addRelationshipWithType:@"childInFamily" target:fam];
```

is equivalent to:

```
0 @FAM1@ FAM
1 HUSB @INDI1@
1 WIFE @INDI2@
1 CHIL @INDI3@
0 @INDI1@ INDI
1 NAME Jens /Hansen/
1 SEX M
1 FAMS @FAM1@
0 @INDI2@ INDI
1 NAME Anne /Larsdatter/
1 SEX F
1 FAMS @FAM1@
0 @INDI3@ INDI
1 NAME Hans /Jensen/
1 SEX M
1 FAMC @FAM1@
```

======

Test files used to verify GEDCOM compliance are from [Heiner Eichmann's GEDCOM 5.5 Sample Page](http://www.heiner-eichmann.de/gedcom/gedcom.htm) and [GEDitCOM's GEDCOM 5.5 Torture Test Files page](http://www.geditcom.com/gedcom.html) — with minor modifications to facilitate testing:
* allged.ged:
  - line 34 has "English" instead of "language".
  - line 322 has a Hebrew date instead of the original Gregorian date.
* TGC55.ged:
  - All CHAN nodes: Uppercased month names & made times fixed width.