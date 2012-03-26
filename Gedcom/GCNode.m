//
//  GCNode.m
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNode.h"
#import "NSString+GCKitAdditions.h"
#import "GCTag.h"

@interface GCNode ()

- (void)addSubNode: (GCNode *) n;
- (void)addSubNodes: (NSArray *) a;

- (NSArray *)gedcomLinesAtLevel:(int) level;

@property GCNode *parent;
@property GCTag *gedTag;
@property NSString *gedValue;
@property NSString *xref;
@property NSString *lineSeparator;

@end

@implementation GCNode {
    NSMutableArray *_subNodes;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
	if (self) {
        [self setLineSeparator:@"\n"];
        _subNodes = [NSMutableArray arrayWithCapacity:2];
	}
    
	return self;
}

- (id)initWithTag:(GCTag *)tag value:(NSString *)value xref:(NSString *)xr subNodes:(NSArray *)subNodes
{
    NSParameterAssert(tag != nil);
    
    self = [self init];
    
	if (self) {
        [self setGedTag:tag];
        [self setXref:xr];
        [self setGedValue:value];
        
        if (subNodes) {
            _subNodes = [subNodes mutableCopy]; 
        }
	}
    
    return self;
}

#pragma mark Convenience constructors

+ (id)nodeWithTag:(GCTag *)tag value:(NSString *)value
{
    return [[self alloc] initWithTag:tag value:value xref:nil subNodes:nil];
}

+ (id)nodeWithTag:(GCTag *)tag xref:(NSString *)xr
{
    return [[self alloc] initWithTag:tag value:nil xref:xr subNodes:nil];
}

+ (NSArray*)arrayOfNodesFromString:(NSString*) gedString
{
	return [GCNode arrayOfNodesFromArrayOfStrings:[gedString arrayOfLines]];
}

+ (NSArray*)arrayOfNodesFromArrayOfStrings:(NSArray*) gedLines
{
	NSMutableArray *gedArray = [NSMutableArray arrayWithCapacity:5];
    
    int currentLevel = 0;
    GCNode *currentNode = nil;
	
	//NSMutableDictionary *currentNodes = [NSMutableDictionary dictionaryWithCapacity:5];
	
	NSLog(@"Began parsing gedcom.");
	
    
    NSRegularExpression *levelTagValueRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d) ([A-Z]{3,4}[0-9]?)(?: (.*))?$"
                                                                                        options:0 
                                                                                          error:nil];
    NSRegularExpression *levelXrefTagRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d) (\\@[A-Z_]+\\d*\\@) ([A-Z]{3,4})$" 
                                                                                       options:0 
                                                                                         error:nil];
    NSRegularExpression *levelCustomTagValueRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d) (_[A-Z][A-Z0-9]*)(?: (.*))?$"
                                                                                              options:0
                                                                                                error:nil];
	
	for (NSString *gLine in gedLines) {
		if ([gLine isEqualToString:@""]) 
			continue;
		
		GCNode* node = nil;
        
        NSRange range = NSMakeRange(0, [gLine length]);
		int level = -1;
		
		NSTextCheckingResult *match = [levelTagValueRegex firstMatchInString:gLine options:0 range:range];
        
		if ([match numberOfRanges] == 4) {
			level = [[gLine substringWithRange:[match rangeAtIndex:1]] intValue];
            NSString *val = nil;
            if ([match rangeAtIndex:3].length > 0) {
                val = [gLine substringWithRange:[match rangeAtIndex:3]];
            }
            node = [GCNode nodeWithTag:[GCTag tagCoded:[gLine substringWithRange:[match rangeAtIndex:2]]] 
                                 value:val];
		} else {
			match = [levelXrefTagRegex firstMatchInString:gLine options:0 range:range];
			if ([match numberOfRanges] == 4) {
				level = [[gLine substringWithRange:[match rangeAtIndex:1]] intValue];
                node = [GCNode nodeWithTag:[GCTag tagCoded:[gLine substringWithRange:[match rangeAtIndex:3]]]
                                      xref:[gLine substringWithRange:[match rangeAtIndex:2]]];
			} else {
				match = [levelCustomTagValueRegex firstMatchInString:gLine options:0 range:range];
				if ([match numberOfRanges] == 4) {
					NSLog(@"Custom gedcom tag: %@", [gLine substringWithRange:[match rangeAtIndex:2]]);
					level = [[gLine substringWithRange:[match rangeAtIndex:1]] intValue];
                    node = [GCNode nodeWithTag:[GCTag tagCoded:[gLine substringWithRange:[match rangeAtIndex:2]]]
                                         value:[gLine substringWithRange:[match rangeAtIndex:3]]];
				} else {
					NSLog(@"Malformed Gedcom line had result: %@ -- %@", gLine, match);
				}
			}
		}
        
        if (node == nil) {
            NSLog(@"Unable to create node from gedcom: %@", gLine);
            //throw?
        }
		
        if (level == 0) { //root
            [gedArray addObject:node];
        } else if (level == currentLevel+1) { //child of current
            [currentNode addSubNode:node];
        } else { //find correct parent
            GCNode *parent = currentNode;
            for (int i = currentLevel; i >= level; i--) {
                parent = [parent parent];
            }
            [parent addSubNode:node];
        }
        
        currentLevel = level;
        currentNode = node;
	}
    
	NSLog(@"Finished parsing gedcom.");
	
	return [gedArray copy];
}

#pragma mark Gedcom output

- (NSString *)gedcomString
{
	return [[self gedcomLinesAtLevel:0] componentsJoinedByString:[self lineSeparator]];
}

- (NSArray *)gedcomLines
{
	return [self gedcomLinesAtLevel:0];
}

- (NSArray *)gedcomLinesAtLevel:(int) level
{
	NSMutableArray *gedLines = [NSMutableArray arrayWithCapacity:5];
	
	if ([[self xref] isEqualToString:@""]) {
		[self setXref:nil];
	}
	
	if ([[self gedValue] isEqualToString:@""]) {
		[self setGedValue:nil];
	} else {
		NSMutableArray *lines = [[[self gedValue] arrayOfLines] mutableCopyWithZone:NULL];
		
		NSString *s = [lines objectAtIndex:0];
		[lines removeObjectAtIndex:0];
		
		level++;
		for (NSString *line in lines) {
			NSString *t = @"CONT"; //we use CONT for new lines
			
			if ([line length] <= 248) {
				s = [s stringByAppendingFormat:@"\n%d %@ %@", level, t, line];
			} else {
				//split string in 248-char parts, loop & add as CONC
				NSString *leftover = line;
				
				while ([leftover length] > 248) {
					NSString *bite = [leftover substringToIndex:248];
					leftover = [leftover substringFromIndex:248];
					
					s = [s stringByAppendingFormat:@"\n%d %@ %@", level, t, bite];
					
					t = @"CONC"; //and CONC for concatenations
				}
				
				s = [s stringByAppendingFormat:@"\n%d %@ %@", level, t, leftover];
			}
		}
		level--;
		
		[self setGedValue:s];
	}
	
	if ([self xref] != nil && [self gedValue] == nil) {
		[gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level, [self xref], [[self gedTag] code]]];
	} else if ([self xref] == nil && [self gedValue] != nil) {
		[gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level, [[self gedTag] code], [self gedValue]]];
	} else if ([self xref] != nil && [self gedValue] != nil) {
		[gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level, [self xref], [[self gedTag] code]]];
		[gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level+1, @"CONT", [self gedValue]]];
	} else {
		[gedLines addObject:[NSString stringWithFormat:@"%d %@", level, [[self gedTag] code]]];
	}
	
	level++;
	for (id subNode in [self subNodes] ) {
		[gedLines addObjectsFromArray:[subNode gedcomLinesAtLevel:level]];
	}
	level--;
	
	return gedLines;
}

#pragma mark Subnode access

-(GCNode *)subNodeForTagPath:(NSString *)tagPath
{
	//TODO complain if more than one are found?
	return [[self subNodesForTagPath:tagPath] objectAtIndex:0];
}

-(NSArray *)subNodesForTagPath:(NSString *)tagPath
{
	NSMutableArray *a = [NSMutableArray arrayWithCapacity:5];
	
	NSMutableArray *ta = [[tagPath componentsSeparatedByString:@"."] mutableCopy];
	NSString *first = [ta objectAtIndex:0];
	[ta removeObjectAtIndex:0];
	
    for (id subNode in [self subNodes]) {
		if ([first isEqualTo:[subNode gedTag]])
			if ([ta count] > 0) {
				[a addObjectsFromArray:[subNode subNodesForTagPath:[ta componentsJoinedByString:@"."]]];
			} else {
				[a addObject:subNode];
			}
	}
	
	return a;
}

-(GCNode *)subNodeForTag:(NSString *)tag
{
    for (id subNode in [self subNodes]) {
		if ([tag isEqualTo:[subNode gedTag]]) {
			return subNode;
		}
	}
	
	return nil;
}

-(NSArray *)subNodesForTag:(NSString *)tag
{
	NSMutableArray *a = [NSMutableArray arrayWithCapacity:5];
	
    for (id subNode in [self subNodes]) {
		if ([tag isEqualTo:[subNode gedTag]]) {
			[a addObject:subNode];
		}
	}
	
	//NSLog(@"subNodes for %@: %@", tag, a);
	
	return a;
}

- (void)addSubNode:(GCNode *) n
{
	if (self == n) {
		NSLog(@"ACCESS DENIED: Attempted to add %@ to itself!", self);
		return;
	}
    
	[_subNodes addObject:n];
    [n setParent:self];
}

- (void)addSubNodes:(NSArray *)a
{
	for (id subNode in a) {
		[self addSubNode:subNode];
	}
}

#pragma mark Description

- (NSString *)description
{
    //return [[self gedTag] code];
	return [NSString stringWithFormat:@"[GCNode tag: %@ xref: %@ value: %@ (subNodes: %@)]", [self gedTag], [self xref], [self gedValue], [self subNodes]];
}

#pragma mark NSCoding conformance

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder setValue:[self gedTag] forKey:@"gedTag"];
    [encoder setValue:[self gedValue] forKey:@"gedValue"];
    [encoder setValue:[self xref] forKey:@"xref"];
    [encoder setValue:[self lineSeparator] forKey:@"lineSeparator"];
    [encoder setValue:[self subNodes] forKey:@"subNodes"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
    
    if (self) {
        [self setGedTag:[decoder decodeObjectForKey:@"gedTag"]];
        [self setGedValue:[decoder decodeObjectForKey:@"gedValue"]];
        [self setXref:[decoder decodeObjectForKey:@"xref"]];
        [self setLineSeparator:[decoder decodeObjectForKey:@"lineSeparator"]];
        _subNodes = [decoder decodeObjectForKey:@"subNodes"];
	}
    
    return self;
}

#pragma mark NSCopying conformance

- (id)copyWithZone:(NSZone *)zone
{
    GCNode *copy = [[GCNode allocWithZone:zone] init];
    
    [copy setValue:[self gedTag] forKey:@"gedTag"];
    [copy setValue:[self gedValue] forKey:@"gedValue"];
    [copy setValue:[self xref] forKey:@"xref"];
    [copy setValue:[self lineSeparator] forKey:@"lineSeparator"];
    [copy setValue:[self subNodes] forKey:@"subNodes"];
    
    return copy;
}

#pragma mark Properties

@synthesize parent;
@synthesize gedTag;
@synthesize gedValue;
@synthesize xref;
@synthesize lineSeparator;
@synthesize subNodes = _subNodes;

@end
