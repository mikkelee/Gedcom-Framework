# README #

**Note**: A work in progress. Selectors & classes may change name / appear / disappear.

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
* Attribute values are handled via subclasses of GCValue, which can be hold one of many types (like NSValue). Sorting and formatters are provided. The types are:
    - GCGender
    - GCAge (parsed via ParseKit)
    - GCDate (parsed via ParseKit)
    - GCString
    - GCNumber
    - GCBool
* Eventually, there may be another layer with things like GCIndividual, GCFamily (?).

The intent is to hide the GEDCOM specifics, but to allow access if required.

Full AppleDoc documentation in the headers, can be built with the Documentation target.

# TODO #

* **tags.json**: Currently only partially done
* **Unit tests**: Better (full) code coverage
* **GCValue**: more helpers & convenience methods (ie GCDate -containsDate:(GCDate *)date)
* **GCContext**: predicate search helpers?

# Examples #

``` objective-c
	GCContext *ctx = [GCContext context];
	
    GCEntity *indi = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
    
    NSArray *names = [NSArray arrayWithObjects:
                      [GCString valueWithGedcomString:@"Jens /Hansen/"], 
                      [GCString valueWithGedcomString:@"Jens /Hansen/ Smed"], 
                      nil];
    
    [indi setValue:names 
            forKey:@"name"];
	
    //alternately:
    // [indi addAttributeWithType:@"Name" value:[GCString valueWithGedcomString:@"Jens /Hansen/"]];
    
	GCAttribute *birt = [GCAttribute attributeWithType:@"birth"];
    
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    
    [[indi properties] addObject:birt];
    
    //alternately:
    // [indi addProperty:birt];
    // [[indi valueForKey:[birt type]] addObject:birt];
    
    [indi addAttributeWithType:@"death" value:[GCBool yes]];
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
	
	GCEntity *husb = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
	[husb addAttributeWithType:@"name" value:[GCString valueWithGedcomString:@"Jens /Hansen/"]];
	[husb addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
	GCEntity *wife = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
	[wife addAttributeWithType:@"name" value:[GCString valueWithGedcomString:@"Anne /Larsdatter/"]];
	[wife addAttributeWithType:@"sex" value:[GCGender femaleGender]];
	
	GCEntity *chil = [GCEntity entityWithType:@"individualRecord" inContext:ctx];
	[chil addAttributeWithType:@"name" value:[GCString valueWithGedcomString:@"Hans /Jensen/"]];
	[chil addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
    GCEntity *fam = [GCEntity entityWithType:@"familyRecord" inContext:ctx];
    
    [fam setValue:husb forKey:@"husband"];
    [fam setValue:wife forKey:@"wife"];
    [fam setValue:[NSArray arrayWithObject:chil] forKey:@"child"];
    
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
