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

- (NSArray *)gedcomLinesAtLevel:(int) level;

@property (weak) GCNode *parent;
@property NSString *gedTag;
@property NSString *gedValue;
@property NSString *xref;
@property NSString *lineSeparator;

@end

@implementation GCNode {
    NSMutableOrderedSet *_subNodes;
}

static NSString *concSeparator;

#pragma mark Initialization

//COV_NF_START
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}
//COV_NF_END

- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSOrderedSet *)subNodes
{
    if (!concSeparator) {
        concSeparator = [NSString stringWithFormat:@"%C", 0x2060];
    }
    
    NSParameterAssert(tag != nil && ([tag length] <= 4 || [tag hasPrefix:@"_"]));
    
    self = [super init];
    
	if (self) {
        [self setLineSeparator:@"\n"];
        [self setGedTag:tag];
        [self setXref:xref];
        [self setGedValue:value];
        
        if (subNodes) {
            _subNodes = [subNodes mutableCopy]; 
        } else {
            _subNodes = [NSMutableOrderedSet orderedSet];
        }
	}
    
    return self;
}

#pragma mark Convenience constructors

+ (NSArray*)arrayOfNodesFromString:(id)gedString
{
    if ([gedString isKindOfClass:[NSAttributedString class]]) {
        gedString = [gedString string];
    }
    
    NSParameterAssert([gedString isKindOfClass:[NSString class]]);
    
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
				[currentNode setGedValue:[NSString stringWithFormat:@"%@%@%@", [currentNode gedValue], concSeparator, val]];
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

void contConcHelper(int level, NSString *inLine, NSString **outInitial, NSArray **outSubLines) {
	NSMutableArray *lines = [[inLine componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    NSString *initial = nil;
    NSMutableArray *subLines = [NSMutableArray array];
    
    for (NSString *line in lines) {
        if ([line length] <= 248 && [line rangeOfString:concSeparator].location == NSNotFound) {
            //line's good to go.
            
            if (initial == nil) {
                initial = line;
            } else {
                //we already set the first line so make a CONT node
                [subLines addObject:[NSString stringWithFormat:@"%d CONT %@", level+1, line]];
            }
        } else {
            //we need to split the line on >248 or concSeparator
            
            NSString *leftover = line;
            
            BOOL firstPass = YES;
            
            while ([leftover length] > 248 || [leftover rangeOfString:concSeparator].location != NSNotFound) {
                NSUInteger toIndex = 248; //assume length is the reason
                NSUInteger fromIndex = 248;
                if ([leftover rangeOfString:concSeparator].location != NSNotFound) {
                    // split on concSeparator
                    toIndex = [leftover rangeOfString:concSeparator].location;
                    fromIndex = toIndex + [concSeparator length];
                }
                NSString *bite = [leftover substringToIndex:toIndex];
                leftover = [leftover substringFromIndex:fromIndex];
                
                if (firstPass) {
                    if (initial == nil) {
                        initial = bite;
                    } else {
                        [subLines addObject:[NSString stringWithFormat:@"%d CONT %@", level+1, bite]];
                    }
                } else {
                    //we already set the first line so make a CONC node
                    [subLines addObject:[NSString stringWithFormat:@"%d CONC %@", level+1, bite]];
                }
                
                firstPass = NO;
            }
            
            [subLines addObject:[NSString stringWithFormat:@"%d CONC %@", level+1, leftover]];
        }
    }
    
    *outInitial = initial;
    *outSubLines = [subLines copy];
    
    //NSLog(@"outInitial: %@", *outInitial);
    //NSLog(@"outSubLines: %@", *outSubLines);
}

- (NSArray *)gedcomLinesAtLevel:(int) level
{
	NSMutableArray *gedLines = [NSMutableArray array];
    
    NSString *firstLine = nil;
    NSArray *subLineNodes = nil;
	
    contConcHelper(level, [self gedValue], &firstLine, &subLineNodes);
    
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
    
    [gedLines addObjectsFromArray:subLineNodes];
    
	for (id subNode in [self subNodes] ) {
		[gedLines addObjectsFromArray:[subNode gedcomLinesAtLevel:level+1]];
	}
	
	return gedLines;
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForKey:(NSString *)key
{
    BOOL isTagKey = [[key uppercaseString] isEqualToString:key] && ([key length] == 4 || [key length] == 3 || [key hasPrefix:@"_"]);
    
    if (isTagKey) {
        NSMutableArray *subNodes = [NSMutableArray array];
        
        for (id subNode in [self subNodes]) {
            if ([[subNode gedTag] isEqualTo:key]) {
                [subNodes addObject:subNode];
            }
        }
        
        if ([subNodes count] > 1) {
            return [subNodes copy];
        } else if ([subNodes count] == 1) {
            return [subNodes lastObject];
        } else {
            return nil;
        }
	} else {
        return [super valueForKey:key];
	}
}

#pragma mark Adding subnodes

- (void)addSubNode:(GCNode *)node
{
	NSParameterAssert(self != node);
    
	[_subNodes addObject:node];
	[node setParent:self];
}

/*
#pragma mark Comparison

- (BOOL)isEqual:(GCNode *)other
{
    if (![[self gedTag] isEqualToString:[other gedTag]]) {
        return NO;
    }
    
    if ([self gedValue] && ![[self gedValue] isEqualToString:[other gedValue]]) {
        return NO;
    }
    
    if ([self xref] && ![[self xref] isEqualToString:[other xref]]) {
        return NO;
    }
    
    if (![[[self subNodes] set] isEqualToSet:[[other subNodes] set]]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return [[self gedTag] hash] + [[self xref] hash] + [[self gedValue] hash] + [[[self subNodes] set] hash];
}
*/

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCNode tag: %@ xref: %@ value: %@ (subNodes: %@)]", [self gedTag], [self xref], [self gedValue], [self subNodes]];
}
//COV_NF_END

#pragma mark NSCoding conformance

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self gedTag] forKey:@"gedTag"];
    [encoder encodeObject:[self gedValue] forKey:@"gedValue"];
    [encoder encodeObject:[self xref] forKey:@"xref"];
    [encoder encodeObject:[self lineSeparator] forKey:@"lineSeparator"];
    [encoder encodeObject:[self subNodes] forKey:@"subNodes"];
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
    
    for (id subNode in _subNodes) {
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

@implementation GCNode (GCConvenienceMethods)

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value
{
    return [[self alloc] initWithTag:tag value:value xref:nil subNodes:nil];
}

+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref
{
    return [[self alloc] initWithTag:tag value:nil xref:xref subNodes:nil];
}

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value subNodes:(NSOrderedSet *)subNodes
{
    return [[self alloc] initWithTag:tag value:value xref:nil subNodes:subNodes];
}

+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref subNodes:(NSOrderedSet *)subNodes
{
    return [[self alloc] initWithTag:tag value:nil xref:xref subNodes:subNodes];
}

@end
