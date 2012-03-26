# README #

**Note**: A work in progress. Selectors may change name / appear / disappear.

A number of classes to ease GEDCOM 5.5-manipulation in Cocoa through layers of abstraction:

* GEDCOM text <=> GCNode <=> GCRecord
* Closest to the metal are GCNodes, a simple representation of the nested structure of GEDCOM text data.
* Above GCNodes are GCRecords, which allow for more abstracted data access, including automatic handling of value types, references, etc.
* Eventually, there should be things like GCIndividual with appropriate accessors.

The intent is to hide the GEDCOM specifics, but to allow access if required.

Currently, GCNodes are fully implemented; work is being done on GCRecord / GCValue / GCTag. See also TODO below.

Additionally, parsing and handling of ages and dates per 5.5 spec via ParseKit; handles ranges & periods, allows for sorting.

Example, from top to bottom:

``` objective-c
    GCRecord *indi = [GCRecord objectWithType:@"Individual"];
    
    [indi addRecordWithType:@"Name" stringValue:@"Jens /Hansen/"];
    [indi addRecordWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
    GCRecord *birt = [GCRecord objectWithType:@"Birth"];
    
    [birt addRecordWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    [indi addRecord:birt];
    
    [indi addRecordWithType:@"Death" boolValue:YES];
```

is equivalent to:

``` objective-c

    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagCoded:@"INDI"] 
                                         value:nil
                                          xref:nil
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
0 @I1@ INDI
1 NAME Jens /Hansen/
1 NAME Jens /Hansen/ Smed
1 BIRT
2 DATE 1 JAN 1901
1 DEAT Y
```

# TODO #

* **tags.plist**: complete tags dict & tagAliases
* **GCNode**: subNodes array shouldn't be mutable (GCNode should be fully immutable)
* **GCNode**: CONC/CONT consistency: parse during read & coalesce? keep weird things like CONC on <248 char lines?
* **GCMutableNode**: Mutable version of GCNode
* **GCObject**: xref generator
* **GCObject**: parent ref
* **GCValue**: type coercions
* **GCAge/GCDate**: better hiding of internals (ie a facade) - should remain immutable; interface should basically just be input gedcom, get out instance.
* **GCAge/GCDate**: calculations (ie dateA - dateB = age)
* **appledocs**: and better comments in general
