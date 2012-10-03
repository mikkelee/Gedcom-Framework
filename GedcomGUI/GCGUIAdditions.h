//
//  GCGUIAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 27/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Gedcom/Gedcom.h>

@interface GCObject (GCGUIAdditions)

+ (NSArray *)defaultPredicateEditorRowTemplates;

@end

@interface GCValue (GCGUIAdditions)

+ (NSArray *)defaultPredicateOperators;
- (NSAttributeType)defaultAttributeType;

@end
