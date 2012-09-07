# README #

**Note**: A work in progress. Selectors & classes may change name / appear / disappear.

A number of classes to ease [GEDCOM 5.5](http://www.gedcom.net/0g/gedcom55/)-manipulation in Cocoa through layers of abstraction. The intent is to hide the GEDCOM specifics, but to allow access if required. A short summary of the functionality follows:

* GEDCOM is parsed and serialized in layers: text <=> GCNode <=> GCObject.
* Closest to the metal are GCNodes, a simple representation of the nested structure of GEDCOM text data.
* Above GCNodes are GCObjects, which allow for more abstracted data access. There are two basic types of GCObject:
    - GCEntity: Root level records - INDI, FAM, etc.
    - GCProperty: Objects can have a number of properties of which there are two kinds:
        * GCAttribute: Any node that describes an object - NAME, DATE, PLAC, etc.
        * GCRelationship: Any node that references other entities - FAMC, HUSB, ASSO, etc.
* Mapping between GCNodes and GCObjects is helped by GCTags which know what subtags are valid, what type a value is, whether it's an entity or a property, etc.
* Relationship xrefs are handled with a GCContext that ensures that all GCEntities have a 1-to-1 mapping with an xref.
* Attribute values are handled via subclasses of GCValue, which can be one of several types (like NSValue). Sorting and formatters are provided. The types are:
    - GCGender
    - GCAge (parsed via ParseKit)
    - GCDate (parsed via ParseKit)
    - GCString
    - GCNamestring
    - GCPlacestring
    - GCNumber
    - GCBool
* Eventually, there may be another layer with things like GCIndividual, GCFamily (this is undecided at the moment).

Full AppleDoc documentation in the headers, can be built with the Documentation target.

A simple GUI is included that can open a .ged file; it will display a list of the individuals with names and birth data, and allow the user to inspect the structure, as well as experiment with editing the Gedcom data directly, and see how it is parsed. Saving is not currently enabled to prevent accidental data loss. [Screenshot as of May 31, 2012](https://github.com/mikkelee/Gedcom-Framework/raw/master/screenshot.png)

# TODO #

Loosely prioritized in order of importance:

* **tags.json**: Currently only partially done (but is able to read a real-world example generated by GEDitCOM II; output validity is unconfirmed due to node-ordering, but appears correct - more testing needed though)
* **tags.json**: refactor @shortcuts to enable searching for & sorting @events seperately, etc.
* **GCDate**: Comparison should take into account qualifiers.
* **GCValue**: More helpers & convenience methods (ie GCDate -containsDate:(GCDate *)date)
* **Unit tests**: Full code coverage
* **Misc**: Handle special cases; see SOURCE_CITATION in spec. Probably retool reverseRelationship HUSB/WIFE logic.
* **Misc**: More delegates & customization (colors in attributed gedcom strings etc)
* **GCTag**: Some handling of custom tags. Encountered so far: FAM._UMR (unmarried), OBJE._FILE (file path).
* **tags.py**: convenience methods? (-[GCIndividualEntity addBirthWithValue:])

# Examples #

Showing some different ways to add attributes to an object:

``` objective-c
	GCContext *ctx = [GCContext context];
	
    GCIndividualEntity *indi = [GCIndividualEntity individualInContext:ctx];
    
    NSArray *names = [NSArray arrayWithObjects:
                      [GCNamestring valueWithGedcomString:@"Jens /Hansen/"], 
                      [GCNamestring valueWithGedcomString:@"Jens /Hansen/ Smed"], 
                      nil];
    
    [indi setValue:names 
            forKey:@"personalNames"];
	
	GCBirthAttribute *birt = [GCBirthAttribute birth];
    
	[birt addAttributeWithType:@"date" value:[GCDate valueWithGedcomString:@"1 JAN 1901"]];
    
    [[indi mutableArrayValueForKey:@"properties"] addObject:birt];
    
    [indi addAttributeWithType:@"death" value:[GCBool yes]];
```

The above is equivalent to the following GCNode:

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
	
	GCEntity *husb = [GCEntity entityWithType:@"individual" inContext:ctx];
	[husb addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Jens /Hansen/"]];
	[husb addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
	GCEntity *wife = [GCEntity entityWithType:@"individual" inContext:ctx];
	[wife addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Anne /Larsdatter/"]];
	[wife addAttributeWithType:@"sex" value:[GCGender femaleGender]];
	
	GCEntity *chil = [GCEntity entityWithType:@"individual" inContext:ctx];
	[chil addAttributeWithType:@"personalName" value:[GCNamestring valueWithGedcomString:@"Hans /Jensen/"]];
	[chil addAttributeWithType:@"sex" value:[GCGender maleGender]];
	
    GCEntity *fam = [GCEntity entityWithType:@"family" inContext:ctx];
    
    [fam setValue:husb forKey:@"husband"];
    [fam setValue:wife forKey:@"wife"];
    [fam setValue:[NSArray arrayWithObject:chil] forKey:@"children"];
    
    //alternately:
	// [fam addRelationshipWithType:@"husband" target:husb];
	// [fam addRelationshipWithType:@"wife" target:wife];
	// [fam addRelationshipWithType:@"child" target:chil];
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
1 FAMC @FAM1@"
```

======

Test files used to verify GEDCOM compliance are from [Heiner Eichmann's GEDCOM 5.5 Sample Page](http://www.heiner-eichmann.de/gedcom/gedcom.htm) -- with minor modifications: node order, removed trailing space on CHAN, etc.
