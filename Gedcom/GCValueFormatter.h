//
//  GCValueFormatter.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 30/04/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 Abstract value formatter class. Use one of the subclasses instead:
 
 GCStringFormatter,
 GCNumberFormatter,
 GCGenderFormatter,
 GCAgeFormatter,
 GCDateFormatter, or
 GCBoolFormatter.
 
 */
@interface GCValueFormatter : NSFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom strings and vice versa. See GCString.
@interface GCStringFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom numbers and vice versa. See GCNumber.
@interface GCNumberFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom genders and vice versa. See GCGender.
@interface GCGenderFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom ages and vice versa. See GCAge.
@interface GCAgeFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom dates and vice versa. See GCDate.
@interface GCDateFormatter : GCValueFormatter

@end

/// NSFormatter subclass for formatting NSStrings as Gedcom bools and vice versa. See GCBool.
@interface GCBoolFormatter : GCValueFormatter

@end
