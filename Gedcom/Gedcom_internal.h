//
//  Gedcom_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 14/05/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#define GCLocalizedString(key, table) NSLocalizedStringWithDefaultValue(key, table, [NSBundle bundleForClass:[self class]], key, nil)