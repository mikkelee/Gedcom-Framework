# README #

**Note**: A work in progress. Selectors may change name / appear / disappear. Currently, GCNodes are fully implemented; a basic implementation of GCObject and its subclasses is done. Most work is done in KVC/KVO & tags.json.

A number of classes to ease GEDCOM 5.5-manipulation in Cocoa through layers of abstraction:

* GEDCOM text <=> GCNode <=> GCObject
* Closest to the metal are GCNodes, a simple representation of the nested structure of GEDCOM text data.
* Above GCNodes are GCObjects, which allow for more abstracted data access. There are two basic types of GCObject:
  * GCEntity: Root level records - INDI, FAM, etc.
  * GCProperty: Describes an entity. There are two kinds of properties:
    * GCAttribute: Any non-relationship node - NAME, DATE, PLAC, etc.
    * GCRelationship: References to other entities - FAMC, HUSB, etc.
* Mapping between GCNodes and GCObjects is helped by GCTags which know what subtags are valid, what type a value is, whether it's an entity or a property, etc.
* Xrefs are handled with a GCContext that ensures that all GCEntities have a 1-to-1 mapping with an xref.
* Property values are handled via GCValue, which can be hold one of many types (like NSValue). Sorting is supported. The types are:
  * GCGenderValue
  * GCAgeValue (parsed via ParseKit)
  * GCDateValue (parsed via ParseKit)
  * GCStringValue
  * GCNumberValue
  * GCBoolValue
* Eventually, there may be another layer with things like GCIndividual, GCFamily (?).

The intent is to hide the GEDCOM specifics, but to allow access if required.

# TODO #

* **tags.json**: Currently only partially done
* **GCMutableNode**: Mutable version of GCNode
* **GCDate**: better hiding of internals (ie a proper class cluster) - should remain immutable; interface should basically just be input gedcom, get out instance.
* **GCAge/GCDate**: calculations (ie age = dateA - dateB)
* **appledocs**: and better comments & cleaner headers in general
* **GCObject**: NSCoding


# Examples #

``` objective-c
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	
    [indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	[indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
	GCAttribute *birt = [GCAttribute attributeForObject:indi withType:@"Birth"];
    
	[birt addAttributeWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    [indi addAttribute:birt];
    
    [indi addAttributeWithType:@"Death" boolValue:YES];
```

is equivalent to (note [GCTag tagWithType:@"GCEntity" code:@"INDI"] is equivalent to [GCTag tagNamed:@"Individual record"]):

``` objective-c
    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagWithType:@"GCEntity" code:@"INDI"] 
                                         value:nil
                                          xref:@"@INDI1@"
                                      subNodes:[NSArray arrayWithObjects:
                                                [GCNode nodeWithTag:[GCTag tagWithType:@"GCAttribute" code:@"NAME"] 
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:[GCTag tagWithType:@"GCAttribute" code:@"NAME"] 
                                                              value:@"Jens /Hansen/"],
                                                [[GCNode alloc] initWithTag:[GCTag tagWithType:@"GCAttribute" code:@"BIRT"] 
                                                                      value:nil
                                                                       xref:nil
                                                                   subNodes:[NSArray arrayWithObjects:
                                                                             [GCNode nodeWithTag:[GCTag tagWithType:@"GCAttribute" code:@"DATE"]
                                                                                                           value:@"1 JAN 1901"],
                                                                              nil]
                                                                             ],
                                                [GCNode nodeWithTag:[GCTag tagWithType:@"GCAttribute" code:@"DEAT"] 
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
	GCContext *ctx = [GCContext context];
	
	GCEntity *husb = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	[husb addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/"];
	[husb addAttributeWithType:@"Sex" genderValue:GCMale];
	
	GCEntity *wife = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	[wife addAttributeWithType:@"Name" stringValue:@"Anne /Larsdatter/"];
	[wife addAttributeWithType:@"Sex" genderValue:GCFemale];
	
	GCEntity *chil = [GCEntity entityWithType:@"Individual record" inContext:ctx];
	[chil addAttributeWithType:@"Name" stringValue:@"Hans /Jensen/"];
	[chil addAttributeWithType:@"Sex" genderValue:GCMale];
	
    GCEntity *fam = [GCEntity entityWithType:@"Family record" inContext:ctx];
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

======

Test files for GEDCOM compliance are from http://www.heiner-eichmann.de/gedcom/gedcom.htm (with minor modifications: node order, trailing space on CHAN, etc)
