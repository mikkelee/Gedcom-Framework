//
//  GCObject_internal.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 06/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject.h"

#import "GCTag.h"

@interface GCObject () {
@protected
    BOOL _isBuildingFromGedcom;
}

#pragma mark Misc

- (NSString *)_propertyDescriptionWithIndent:(NSUInteger)level;

#pragma mark Objective-C properties

@property (nonatomic, readonly) NSMutableArray *mutableCustomProperties;

@property (nonatomic) NSArray *subNodes;

@property (nonatomic, readonly) NSUndoManager *undoManager;

@property (nonatomic, readonly) GCTag *gedTag;

@end