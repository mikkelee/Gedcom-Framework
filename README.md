# README #

**Note**: A work in progress. Selectors may change name / appear / disappear. Currently, GCNodes are fully implemented; a basic implementation of GCObject and its subclasses is done. Most work is done in KVC/KVO & tags.json.

A number of classes to ease GEDCOM 5.5-manipulation in Cocoa through layers of abstraction:

* GEDCOM text <=> GCNode <=> GCObject
* Closest to the metal are GCNodes, a simple representation of the nested structure of GEDCOM text data.
* Above GCNodes are GCObjects, which allow for more abstracted data access. There are two basic types of GCObject:
    - GCEntity: Root level records - INDI, FAM, etc.
    - GCProperty: Describes an entity. There are two kinds of properties:
        * GCAttribute: Any non-relationship node - NAME, DATE, PLAC, etc.
        * GCRelationship: References to other entities - FAMC, HUSB, etc.
* Mapping between GCNodes and GCObjects is helped by GCTags which know what subtags are valid, what type a value is, whether it's an entity or a property, etc.
* Xrefs are handled with a GCContext that ensures that all GCEntities have a 1-to-1 mapping with an xref.
* Property values are handled via GCValue, which can be hold one of many types (like NSValue). Sorting is supported. The types are:
    - GCGenderValue
    - GCAgeValue (parsed via ParseKit)
    - GCDateValue (parsed via ParseKit)
    - GCStringValue
    - GCNumberValue
    - GCBoolValue
* Eventually, there may be another layer with things like GCIndividual, GCFamily (?).

The intent is to hide the GEDCOM specifics, but to allow access if required.

Full AppleDoc documentation in the headers, can be built with the Documentation target.

# TODO #

* **tags.json**: Currently only partially done
* **GCObject**: NSCoding
* **GCObject**: something like -propertiesFulfillingBlock:
* **GCDate**: helpers should accept more values (like containsDate:(GCDate *)date)
* **GCObject/GCProperty**: Should throw on init if [self class] is obj/prop
* **GCMutableNode**: removeSubNode:, use GCMutableOrderedSetProxy
* **GCChangedDateFormatter**: Make a true formatter
* **GCValue**: Make GCAge/GCDate subclass of GCValue?
* **GCContext**: +contextNamed: - refactor methodnames
* **GCRelationship**: make sure reverse relationships are removed when necessary
* **GCEntity**: lastModified should update when adding/removing properties

# Examples #

``` objective-c
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"Individual record" inContext:ctx];
    
    NSArray *names = [NSArray arrayWithObjects:
                      [GCValue valueWithString:@"Jens /Hansen/"], 
                      [GCValue valueWithString:@"Jens /Hansen/ Smed"], 
                      nil];
    
    [indi setValue:names 
            forKey:@"Name"];
	
    //alternately:
    // [indi addAttributeWithType:@"Name" value:[GCValue valueWithString:@"Jens /Hansen/"]];
	// [indi addAttributeWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
	GCAttribute *birt = [GCAttribute attributeWithType:@"Birth"];
    
	[birt addAttributeWithType:@"Date" dateValue:[GCDate dateWithGedcom:@"1 JAN 1901"]];
    
    [[indi properties] addObject:birt];
    
    //alternately:
    // [indi addProperty:birt];
    // [[indi valueForKey:[birt type]] addObject:birt];
    
    [indi addAttributeWithType:@"Death" boolValue:YES];
```

is equivalent to:

``` objective-c
    GCNode *node = [[GCNode alloc] initWithTag:@"INDI" 
                                         value:nil
                                          xref:@"@INDI1@"
                                      subNodes:[NSArray arrayWithObjects:
                                                [GCNode nodeWithTag:@"NAME" 
                                                              value:@"Jens /Hansen/ Smed"],
                                                [GCNode nodeWithTag:@"NAME" 
                                                              value:@"Jens /Hansen/"],
                                                [[GCNode alloc] initWithTag:@"BIRT" 
                                                                      value:nil
                                                                       xref:nil
                                                                   subNodes:[NSArray arrayWithObjects:
                                                                             [GCNode nodeWithTag:@"DATE"
                                                                                           value:@"1 JAN 1901"],
                                                                              nil]
                                                                             ],
                                                [GCNode nodeWithTag:@"DEAT" 
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
    
    [fam setValue:husb forKey:@"Husband"];
    [fam setValue:wife forKey:@"Wife"];
    [fam setValue:[NSArray arrayWithObject:chil] forKey:@"Child"];
    
    //alternately:
	// [fam addRelationshipWithType:@"Husband" target:husb];
	// [fam addRelationshipWithType:@"Wife" target:wife];
	// [fam addRelationshipWithType:@"Child" target:chil];
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
