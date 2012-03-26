# README #

**Note**: A work in progress. Selectors may change name / appear / disappear.

A number of classes to ease GEDCOM 5.5-manipulation in Cocoa through layers of abstraction:

* Lowest are the GCNodes, a simple representation of the nested structure of GEDCOM data.
* Above GCNodes are GCObjects.

Example:

``` objective-c
    GCObject *indi = [GCObject objectWithType:@"Individual"];
    
    GCObject *name = [GCObject objectWithType:@"Name" stringValue:@"Jens /Hansen/"];
    
    [indi addRecord:name];
    
    GCObject *altName = [GCObject objectWithType:@"Name" stringValue:@"Jens /Hansen/ Smed"];
    
    [indi addRecord:altName];
    
    GCObject *birt = [GCObject objectWithType:@"Birth"];
    GCObject *date = [GCObject objectWithType:@"Date" dateValue:[GCDate dateFromGedcom:@"1 JAN 1901"]];
    
    [birt addRecord:date];
    [indi addRecord:birt];
```

is equivalent to:

``` objective-c

    GCNode *node = [[GCNode alloc] initWithTag:[GCTag tagCoded:@"INDI"] 
                                         value:nil
                                          xref:@"@I1@"
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
                                                 nil]];
    

```

is equivalent to:

```
0 @I1@ INDI
1 NAME Jens /Hansen/
1 NAME Jens /Hansen/ Smed
1 BIRT
2 DATE 1 JAN 1901
```

Additionally, parsing and handling of ages and dates per spec.

# TODO #

* **tags.plist**: complete validSubTags/tagAliases
* **GCNode**: subNodes array shouldn't be mutable (GCNode should be fully immutable)
* **GCNode**: CONC/CONT consistency: parse during read & coalesce? keep weird things like CONC on <248 char lines?
* **GCObject**: xref generator
* **GCObject**: parent ref
* **GCValue**: coercions
* **GCMutableNode**
* **GCAge/GCDate**: better hiding of internals (ie a facade) - should remain immutable; interface should basically just be input gedcom, get out instance.
* **GCAge/GCDate**: calculations (ie dateA - dateB = age)
* **appledocs**: and better comments in general
