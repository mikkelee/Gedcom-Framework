A number of classes to ease GEDCOM-manipulation in Cocoa.

TODO:

- better hiding of GCAge/GCDate internals
- GCMutableNode
- GCTag
- calculations (ie date - date = age)
- validations (subtags, etc)
- CONC/CONT consistency
- "GCObject" something like >

GCObject *indi = [[GCObject alloc] objectOfType:@"Individual"];

GCObject *birth = [[GCObject alloc] objectOfType:@"Birth"];

[birth addValue:@"1 JAN 1901" forKey:@"Date"];

[indi addRecord:birth];

- appledoc docs
