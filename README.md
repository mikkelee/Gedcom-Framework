# README #

**Note**: A work in progress. Selectors may change name / appear / disappear.

A number of classes to ease GEDCOM-manipulation in Cocoa.

# TODO #

* tags.plist: complete validSubTags/tagAliases
* GCNode: initWith... methods
* GCNode: subNodes array shouldn't be mutable
* GCMutableNode
* better hiding of GCAge/GCDate internals (ie facade) - should remain immutable; interface should basically just be input gedcom, get out instance.
* calculations (ie dateA - dateB = age)
* CONC/CONT consistency: parse during read? coalesce? how to keep weird things like CONC on <248 char lines?
* "GCObject" something like:

``` objective-c
    GCObject *indi = [GCObject objectWithType:@"Individual"];
    
    GCObject *birth = [GCObject objectWithType:@"Birth"];
    
    [birth setValue:@"1 JAN 1901" forKey:@"Date"];
    
    [indi addRecord:birth];
```

* appledocs
