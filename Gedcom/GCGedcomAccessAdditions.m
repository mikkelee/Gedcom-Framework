//
//  GCGedcomAccessAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCGedcomAccessAdditions.h"

#import "GCGedcomLoadingAdditions_internal.h"

#import "GCContext+GCKeyValueAdditions.h"

#import "GCObject_internal.h"
#import "GCEntity.h"
#import "GCRecord.h"
#import "GCAttribute.h"
#import "GCRelationship.h"

#import "GCHeaderEntity+GCObjectAdditions.h"
#import "GCTagAccessAdditions.h"

#import "GCNode.h"
#import "GCNodeParser.h"
#import "GCValue.h"

#import "GCContext_internal.h"

__strong static NSDictionary *_defaultColors;

@implementation GCContext (GCGedcomAccessAdditions)

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[self.entities count]];
	
    if (!self.header) {
        self.header = [GCHeaderEntity defaultHeaderInContext:self];
    }
    
    @synchronized (self) {
        for (GCRecord *record in self.entities) {
            [nodes addObject:record.gedcomNode];
        }
	}
    
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

- (NSString *)gedcomString
{
    NSMutableArray *gedcomStrings = [NSMutableArray array];
    
    for (GCNode *node in self.gedcomNodes) {
        [gedcomStrings addObjectsFromArray:node.gedcomLines];
    }
    
    return [gedcomStrings componentsJoinedByString:@"\n"];
}

- (NSData *)gedcomData
{
    GCFileEncoding useEncoding = self.fileEncoding;
    
    NSParameterAssert(useEncoding != GCUnknownFileEncoding);
    NSParameterAssert(useEncoding != GCANSELFileEncoding);
    
    return [self.gedcomString dataUsingEncoding:useEncoding];
}

@end

@implementation GCObject (GCGedcomAccessAdditions)

@dynamic gedcomNode;

+ (void)load
{
    _defaultColors = @{
                       GCLevelAttributeName : [NSColor redColor],
                       GCXrefAttributeName : [NSColor blueColor],
                       GCTagAttributeName : [NSColor darkGrayColor]
                       };
}

- (NSArray *)subNodes
{
    NSMutableArray *subNodes = [NSMutableArray array];
    
    for (GCProperty *property in self.properties) {
        [subNodes addObject:property.gedcomNode];
    }
    
	return subNodes;
}

- (void)setSubNodes:(NSArray *)newSubNodes
{
    NSArray *originalProperties = [self.properties copy];
    
    NSArray *curSubNodes = self.subNodes;
    
    NSUInteger curMarker = 0;
    NSUInteger newMarker = 0;
    
    _isBuildingFromGedcom = YES;
    
    while (newMarker < [newSubNodes count]) {
        //NSLog(@"%ld,%ld", newMarker, curMarker);
        
        if (curMarker >= [curSubNodes count]) {
            //NSLog(@"INSERT %@", newSubNodes[newMarker]);
            [self _addPropertyWithGedcomNode:newSubNodes[newMarker]];
            newMarker++;
        } else if ([curSubNodes[curMarker] isEqualTo:newSubNodes[newMarker]]) {
            //NSLog(@"SKIP; IDENTICAL");
            curMarker++;
            newMarker++;
        } else {
            
            NSUInteger nextIndex = [newSubNodes indexOfObject:curSubNodes[curMarker]
                                                      inRange:NSMakeRange(newMarker, [newSubNodes count]-(newMarker+1))];
            
            if (nextIndex != NSNotFound) {
                for (NSUInteger i = newMarker; i < nextIndex; i++) {
                    //NSLog(@"INSERT %@", newSubNodes[i]);
                    [self _addPropertyWithGedcomNode:newSubNodes[i]];
                }
                newMarker = nextIndex+1;
            } else {
                //NSLog(@"DELETE %@", curSubNodes[curMarker]);
                [self.mutableProperties removeObject:originalProperties[curMarker]];
                curMarker++;
            }
        }
        
    }
    
    _isBuildingFromGedcom = NO;
    
    GCParameterAssert([self.properties count] == [newSubNodes count]);
}

- (NSString *)gedcomString
{
    return [self.gedcomNode gedcomString];
}

- (void)setGedcomString:(NSString *)gedcomString
{
    NSArray *nodes = [GCNodeParser arrayOfNodesFromString:gedcomString];
    
    GCParameterAssert([nodes count] == 1);
    
    GCNode *node = [nodes lastObject];
    
    GCParameterAssert([self.gedcomCode isEqualToString:node.tagCode]);
    
    self.gedcomNode = node;
}

- (NSAttributedString *)attributedGedcomString
{
    NSMutableAttributedString *gedcomString = [self.gedcomNode.attributedGedcomString mutableCopy];
    
    NSDictionary *colors = _defaultColors; //TODO [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)GCColorPreferenceKey];
    
    [gedcomString enumerateAttributesInRange:NSMakeRange(0, [gedcomString length])
                                     options:(kNilOptions)
                                  usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                      if (attrs[GCLevelAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:colors[GCLevelAttributeName] range:range];
                                      } else if (attrs[GCXrefAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:colors[GCXrefAttributeName] range:range];
                                      } else if (attrs[GCTagAttributeName]) {
                                          [gedcomString addAttribute:NSForegroundColorAttributeName value:colors[GCTagAttributeName] range:range];
                                      } else if (attrs[GCLinkAttributeName]) {
                                          NSURL *url = [self.context _recordForXref:attrs[GCLinkAttributeName] create:NO withClass:nil].URL;
                                          [gedcomString addAttribute:NSLinkAttributeName value:url range:range];
                                      } else if (attrs[GCValueAttributeName]) {
                                          //nothing
                                      }
                                  }];
    
    return gedcomString;
}

- (void)setAttributedGedcomString:(NSAttributedString *)attributedGedcomString
{
    self.gedcomString = [attributedGedcomString string];
}

@end

@implementation GCEntity (GCGedcomAccessAdditions)

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedcomCode
								 value:self.takesValue ? self.value.gedcomString : nil
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    [super setSubNodes:gedcomNode.subNodes];
}

@end

@implementation GCRecord (GCGedcomAccessAdditions)

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedcomCode
								 value:self.takesValue ? self.value.gedcomString : nil
								  xref:self.xref
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    NSParameterAssert([gedcomNode.xref isEqualToString:self.xref]);
    
    [super setSubNodes:gedcomNode.subNodes];
}

- (NSString *)displayValue
{
    // TODO ???
    if (self.value)
        return self.value.displayString;
    else
        return self.xref;
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue
                                           attributes:@{NSLinkAttributeName: self.xref}];
}

@end

@implementation GCAttribute (GCGedcomAccessAdditions)

- (GCNode *)gedcomNode
{
    return [[GCNode alloc] initWithTag:self.gedcomCode
								 value:self.value.gedcomString
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    [self setValueWithGedcomString:gedcomNode.gedcomValue];
    
    [super setSubNodes:gedcomNode.subNodes];
}

- (NSString *)displayValue
{
    return self.value.displayString;
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue];
}

@end

@implementation GCRelationship (GCGedcomAccessAdditions)

- (GCNode *)gedcomNode
{
    GCParameterAssert(self.target);
    
    return [[GCNode alloc] initWithTag:self.gedcomCode
								 value:self.target.xref
								  xref:nil
							  subNodes:self.subNodes];
}

- (void)setGedcomNode:(GCNode *)gedcomNode
{
    self.target = [self.context _recordForXref:gedcomNode.gedcomValue create:NO withClass:nil];
    
    [super setSubNodes:gedcomNode.subNodes];
}

- (NSString *)displayValue
{
    return self.target.xref;
}

- (NSAttributedString *)attributedDisplayValue
{
    return [[NSAttributedString alloc] initWithString:self.displayValue
                                           attributes:@{NSLinkAttributeName: self.target.xref}];
}

@end