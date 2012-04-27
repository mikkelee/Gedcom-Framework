//
//  GCNode.m
//  GCParseKitTest
//
//  Created by Mikkel Eide Eriksen on 02/12/09.
//  Copyright 2009 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNode.h"
#import "GCTag.h"

#import "GCMutableNode.h"

@interface GCNode ()

- (void)addSubNode: (GCNode *) n;
- (void)addSubNodes: (NSArray *) a;

- (NSArray *)gedcomLinesAtLevel:(int) level;

@property GCNode *parent;
@property NSString *gedTag;
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
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}

- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSArray *)subNodes
{
    NSParameterAssert(tag != nil);
    
    self = [super init];
    
	if (self) {
        [self setLineSeparator:@"\n"];
        [self setGedTag:tag];
        [self setXref:xref];
        [self setGedValue:value];
        
        if (subNodes) {
            _subNodes = [subNodes mutableCopy]; 
        } else {
            _subNodes = [NSMutableArray array];
        }
	}
    
    return self;
}

#pragma mark Convenience constructors

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value
{
    return [[self alloc] initWithTag:tag value:value xref:nil subNodes:nil];
}

+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref
{
    return [[self alloc] initWithTag:tag value:nil xref:xref subNodes:nil];
}

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value subNodes:(NSArray *)subNodes
{
    return [[self alloc] initWithTag:tag value:value xref:nil subNodes:subNodes];
}

+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref subNodes:(NSArray *)subNodes
{
    return [[self alloc] initWithTag:tag value:nil xref:xref subNodes:subNodes];
}

+ (NSArray*)arrayOfNodesFromString:(NSString*) gedString
{
	NSMutableArray *gedArray = [NSMutableArray array];
	
	__block int currentLevel = 0;
	__block GCNode *currentNode = nil;
	
	NSLog(@"Began parsing gedcom.");
	
	NSRegularExpression *levelXrefTagValueRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d) (?:(\\@[A-Z_]+\\d*\\@) )?([A-Z]{3,4}[0-9]?|_[A-Z][A-Z0-9]*)(?: (.*))?$"
                                                                                            options:kNilOptions 
                                                                                              error:nil];
	
    [gedString enumerateLinesUsingBlock:^(NSString *gLine, BOOL *stop) {
		if ([gLine isEqualToString:@""]) {
			return;
        }
     
		int level = -1;
		GCNode* node = nil;
		
		NSRange range = NSMakeRange(0, [gLine length]);
		NSTextCheckingResult *match = [levelXrefTagValueRegex firstMatchInString:gLine options:kNilOptions range:range];
		
        //NSLog(@"gLine: %@", gLine);
        
        if (match) {
            GCNode *parent = nil;
            
			level = [[gLine substringWithRange:[match rangeAtIndex:1]] intValue];
            
            if (level == 0) { //root
                parent = nil;
            } else if (level == currentLevel+1) { //child of current
                parent = currentNode;
            } else { //find correct parent
                parent = currentNode;
                for (int i = currentLevel; i >= level; i--) {
                    parent = [parent parent];
                }
            }
            
			NSString *xref = nil;
			if ([match rangeAtIndex:2].length > 0) {
				xref = [gLine substringWithRange:[match rangeAtIndex:2]];
			}
            
            NSString *code = [gLine substringWithRange:[match rangeAtIndex:3]];
            
			NSString *val = nil;
			if ([match rangeAtIndex:4].length > 0) {
				val = [gLine substringWithRange:[match rangeAtIndex:4]];
			}
            
			if ([code isEqualToString:@"CONT"]) {
				if ([currentNode gedValue] == nil) {
					[currentNode setGedValue:@""];
				}
				[currentNode setGedValue:[NSString stringWithFormat:@"%@\n%@", [currentNode gedValue], val]];
				return;
			} else if ([code isEqualToString:@"CONC"]) {
				if ([currentNode gedValue] == nil) {
					[currentNode setGedValue:@""];
				}
				[currentNode setGedValue:[NSString stringWithFormat:@"%@\u2060%@", [currentNode gedValue], val]];
				return;
			}
            
            /*
             NSLog(@"level: %d", level);
             NSLog(@"xref: %@", xref);
             NSLog(@"code: %@", code);
             NSLog(@"val: %@", val);
             NSLog(@"type: %@", type);
             */
            
            if (xref) {
                node = [GCNode nodeWithTag:code 
                                      xref:xref];
            } else {
                node = [GCNode nodeWithTag:code 
                                     value:val];
            }
            
            if (parent) {
                [parent addSubNode:node];
            } else {
                [gedArray addObject:node];
            }
            
            currentLevel = level;
            currentNode = node;
        } else {
			NSLog(@"Unable to create node from gedcom: %@", gLine);
			//throw?
		}
	}];
	
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
	NSMutableArray *gedLines = [NSMutableArray array];
	
	NSMutableArray *lines = [[[self gedValue] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    
	NSString *firstLine = nil;
    
    if ([lines count] > 0) {
        firstLine = [lines objectAtIndex:0];
        [lines removeObjectAtIndex:0];
    }
    
    if ([self xref] && ![[self xref] isEqualToString:@""]) {
        [gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level, [self xref], [self gedTag]]];
		if (firstLine && ![firstLine isEqualToString:@""]) {
            [gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level, [self gedTag], firstLine]];
        }
	} else {
		if (firstLine && ![firstLine isEqualToString:@""]) {
            [gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level, [self gedTag], firstLine]];
        } else {
            [gedLines addObject:[NSString stringWithFormat:@"%d %@", level, [self gedTag]]];
        }
    }
	
    //TODO clean up this mess, it's a pain in the ass to follow:
	for (NSString *line in lines) {
		NSString *t = @"CONT"; //we use CONT for new lines
		
		if ([line length] <= 248) {
            if ([line rangeOfString:@"\u2060"].location != NSNotFound) {
                NSUInteger index = [line rangeOfString:@"\u2060"].location;
                
                [gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level+1, t, [line substringToIndex:index]]];
                
                t = @"CONC";
                
                [gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level+1, t, [line substringFromIndex:index+1]]];
            } else {
                [gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level+1, t, line]];
            }
		} else {
			//split string in 248-char parts, loop & add as CONC
			NSString *leftover = line;
			
			while ([leftover length] > 248 || [leftover rangeOfString:@"\u2060"].location != NSNotFound) {
                NSUInteger toIndex = 248;
                NSUInteger fromIndex = 248;
                if ([leftover rangeOfString:@"\u2060"].location != NSNotFound) {
                    toIndex = [leftover rangeOfString:@"\u2060"].location;
                    fromIndex = toIndex + 1;
                }
				NSString *bite = [leftover substringToIndex:toIndex];
				leftover = [leftover substringFromIndex:fromIndex];
				
				[gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level+1, t, bite]];
				
				t = @"CONC"; //and CONC for concatenations
			}
			
			[gedLines addObject:[NSString stringWithFormat:@"%d %@ %@", level+1, t, leftover]];
		}
	}
	
	for (id subNode in [self subNodes] ) {
		[gedLines addObjectsFromArray:[subNode gedcomLinesAtLevel:level+1]];
	}
	
	return gedLines;
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForKey:(NSString *)key
{
	NSMutableArray *subNodes = [NSMutableArray array];
	
    for (id subNode in [self subNodes]) {
		if ([[subNode gedTag] isEqualTo:key]) {
			[subNodes addObject:subNode];
		}
	}
	
	if ([subNodes count] > 1) {
		return subNodes;
	} else if ([subNodes count] == 1) {
		return [subNodes lastObject];
	} else {
        return [super valueForKey:key];
	}
}

#pragma mark Adding subnodes

- (void)addSubNode:(GCNode *) n
{
	NSParameterAssert(self != n);
    
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
    GCNode *copy = [[GCNode allocWithZone:zone] initWithTag:[self gedTag] 
                                                      value:[self gedValue] 
                                                       xref:[self xref] 
                                                   subNodes:[self subNodes]];
    
    [copy setValue:[self lineSeparator] forKey:@"lineSeparator"];
    
    return copy;
}

#pragma mark NSMutableCopying conformance

- (id)mutableCopyWithZone:(NSZone *)zone
{
    GCMutableNode *copy = [[GCMutableNode allocWithZone:zone] initWithTag:[self gedTag] 
                                                                    value:[self gedValue] 
                                                                     xref:[self xref] 
                                                                 subNodes:nil];
    
    [copy setValue:[self lineSeparator] forKey:@"lineSeparator"];
    
    for (id subNode in [self subNodes]) {
        [copy addSubNode:[subNode mutableCopy]];
    }
    
    return copy;
}

#pragma mark Objective-C properties

@synthesize parent = _parent;
@synthesize gedTag = _gedTag;
@synthesize gedValue = _gedValue;
@synthesize xref = _xref;
@synthesize lineSeparator = _lineSeparator;
@synthesize subNodes = _subNodes;

@end
