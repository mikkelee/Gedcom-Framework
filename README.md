# README #

**Note**: A work in progress. Selectors may change name / appear / disappear.

A number of classes to ease GEDCOM 5.5-manipulation in Cocoa through layers of abstraction:

* GEDCOM text <=> GCNode <=> GCObject
* Closest to the metal are GCNodes, a simple representation of the nested structure of GEDCOM text data.
* Above GCNodes are GCObjects, which allow for more abstracted data access. There are three basic types of GCObject:
  * GCEntity: Root level records - INDI, FAM, etc.
  * GCAttribute: Any non-relationship node - NAME, DATE, PLAC, etc.
  * GCRelationship: References to other entities - FAMC, HUSB, etc.
* Eventually, there should be another layer with things like GCIndividual, GCFamily (?).

The intent is to hide the GEDCOM specifics, but to allow access if required.

Currently, GCNodes are fully implemented; a basic implementation of GCObject and its subclasses is done. See also Examples & TODO below.

Additionally, parsing and handling of ages and dates per 5.5 spec via ParseKit; handles ranges & periods, allows for sorting.


# TODO #

* **tags.plist**: Currently only partially done
* **GCNode**: CONC/CONT - currently unable to preserve weird things like CONC on <248 char lines (which is a dumb thing to do anyway, but allowed in spec)
* **GCMutableNode**: Mutable version of GCNode
* **GCValue**: better type coercions; some currently return nil.
* **GCAge/GCDate**: better hiding of internals (ie a proper class cluster) - should remain immutable; interface should basically just be input gedcom, get out instance.
* **GCAge/GCDate**: calculations (ie age = dateA - dateB)
* **appledocs**: and better comments & cleaner headers in general


# Examples #

``` objective-c
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual" inContext:ctx];
	
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
	GCAttribute *birt = [GCAttribute attributeWithType:@"Birth" inContext:ctx];
    
	[birt addAttributeWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    [indi addAttribute:birt];
    
    [indi addAttributeWithType:@"Death" boolValue:YES];
```

is equivalent to:

``` objective-c

    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagCoded:@"INDI"] 
                                         value:nil
                                          xref:@"@INDI1@"
                                      subNodes:[NSArray arrayWithObjects:
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"NAME"] 
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"NAME"] 
                                                              value:@"Jens /Hansen/"],
                                                [[GCNode alloc] initWithTag:[GCTag tagCoded:@"BIRT"] 
                                                                      value:nil
                                                                       xref:nil
                                                                   subNodes:[NSArray arrayWithObjects:
                                                                             [GCNode nodeWithTag:[GCTag tagCoded:@"DATE"]
                                                                                                           value:@"1 JAN 1901"],
                                                                              nil]
                                                                             ],
                                                [GCNode nodeWithTag:[GCTag tagCoded:@"DEAT"] 
                                                              value:@"Y"],
                                                 nil]];
    

```

is equivalent to:

```
0 @INDI1@ INDI
1 NAME Jens /Hansen/
1 NAME Jens /Hansen/ Smed
1 BIRT
2 DATE 1 JAN 1901
1 DEAT Y
```

Relationship example:

```objective-c
	GCEntity *husb = [GCEntity entityWithType:@"Individual" inContext:ctx];
	[husb addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	
	GCEntity *wife = [GCEntity entityWithType:@"Individual" inContext:ctx];
	[wife addAttributeWithType:@"Name" stringValue:@"Anne /Larsdatter/"];
	
	GCEntity *chil = [GCEntity entityWithType:@"Individual" inContext:ctx];
	[chil addAttributeWithType:@"Name" stringValue:@"Hans /Jensen/"];
	
    GCEntity *fam = [GCEntity entityWithType:@"Family" inContext:ctx];
	[fam addRelationshipWithType:@"Husband" target:husb];
	[fam addRelationshipWithType:@"Wife" target:wife];
	[fam addRelationshipWithType:@"Child" target:chil];
```

is equivalent to:

```
0 @FAM1@ FAM
1 HUSB @INDI1@
1 WIFE @INDI2@
1 CHIL @INDI3@
0 @INDI1@ INDI
1 NAME Jens /Hansen/
1 FAMS @FAM1@
0 @INDI2@ INDI
1 NAME Anne /Larsdatter/
1 FAMS @FAM1@
0 @INDI3@ INDI
1 NAME Hans /Jensen/
1 FAMC @FAM1@"
```
