# README #

**Note**: A work in progress. Selectors may change name / appear / disappear.

A number of classes to ease GEDCOM 5.5-manipulation in Cocoa through layers of abstraction:

* Lowest are the GCNodes, a simple representation of the nested structure of GEDCOM data.
* Above GCNodes are GCObjects.

Additionally, parsing and handling of ages and dates per spec.

# TODO #

* **tags.plist**: complete validSubTags/tagAliases
* **GCNode**: initWith... methods
* **GCNode**: subNodes array shouldn't be mutable (GCNode should be fully immutable)
* **GCNode**: CONC/CONT consistency: parse during read & coalesce? keep weird things like CONC on <248 char lines?
* **GCObject**: xrefs - some kind of central authority
* **GCMutableNode**
* **GCAge/GCDate**: better hiding of internals (ie a facade) - should remain immutable; interface should basically just be input gedcom, get out instance.
* **GCAge/GCDate**: calculations (ie dateA - dateB = age)
* **appledocs**
