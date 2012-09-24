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

@property (weak) GCNode *parent;
@property NSString *gedTag;
@property NSString *gedValue;
@property NSString *xref;
@property NSString *lineSeparator;

@end

@implementation GCNode {
    NSMutableArray *_subNodes;
}

static NSString *concSeparator;

#pragma mark Initialization

+ (void)initialize
{
    unichar wordJoiner = 0x2060;
    concSeparator = [NSString stringWithCharacters:&wordJoiner length:1];
}

//COV_NF_START
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];    
    return nil;
}
//COV_NF_END

- (id)initWithTag:(NSString *)tag value:(NSString *)value xref:(NSString *)xref subNodes:(NSArray *)subNodes
{
    NSParameterAssert(tag != nil && ([tag length] <= 4 || [tag hasPrefix:@"_"]));
    
    self = [super init];
    
	if (self) {
        self.lineSeparator = @"\n";
        self.gedTag = tag;
        self.xref = xref;
        self.gedValue = value;
        
        if (subNodes) {
            _subNodes = [subNodes mutableCopy]; 
        } else {
            _subNodes = [NSMutableArray array];
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
	
	//NSLog(@"Began parsing gedcom.");
	
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
                val = [[gLine substringWithRange:[match rangeAtIndex:4]] stringByReplacingOccurrencesOfString:@"@@" withString:@"@"]; // unescape at-sign
			}
            
            // CONT/CONC nodes are continuations of values from the previous node, so fold them up here:
			if ([code isEqualToString:@"CONT"]) {
				if (currentNode.gedValue == nil) {
					currentNode.gedValue = val;
				} else {
                    currentNode.gedValue = [NSString stringWithFormat:@"%@\n%@", currentNode.gedValue, val];
                }
				return;
			} else if ([code isEqualToString:@"CONC"]) {
				if (currentNode.gedValue == nil) {
					currentNode.gedValue = val;
				} else {
					currentNode.gedValue = [NSString stringWithFormat:@"%@%@%@", currentNode.gedValue, concSeparator, val];
                }
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
			NSLog(@"Unable to create node from gedcom: '%@' -- will assume faulty linefeed and append to value of previous node: %@", gLine, currentNode);
            
            if (currentNode.gedValue == nil) {
                currentNode.gedValue = gLine;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@\n%@", currentNode.gedValue, gLine];
            }
		}
	}];
	
#ifdef DEBUG
	NSLog(@"Finished parsing gedcom.");
#endif
    
	return [gedArray copy];
}

#pragma mark Gedcom output

static inline NSAttributedString * attributedString(NSString *string, NSString *attribute, NSString *value) {
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:@{ attribute : value }];
}

void contConcHelper(int level, NSString *inLine, NSString **outInitial, NSArray **outSubLines) {
	NSMutableArray *lines = [[inLine componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    NSString *initial = nil;
    NSMutableArray *subLines = [NSMutableArray array];
    
    NSString *tmp = [NSString stringWithFormat:@"%d", level+1];
    
    NSAttributedString *levelString = attributedString(tmp, GCLevelAttributeName, tmp);
    NSAttributedString *concString = attributedString(@"CONC", GCTagAttributeName, @"CONC");
    NSAttributedString *contString = attributedString(@"CONT", GCTagAttributeName, @"CONT");
    
    for (NSString *line in lines) {
        if ([line length] <= 248 && [line rangeOfString:concSeparator].location == NSNotFound) {
            //line's good to go.
            
            if (initial == nil) {
                initial = line;
            } else {
                //we already set the first line so make a CONT node
                [subLines addObject:@[levelString,
                                     contString,
                                     attributedString(line, GCValueAttributeName, line)]];
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
                        [subLines addObject:@[levelString,
                                             contString,
                                             attributedString(bite, GCValueAttributeName, bite)]];
                    }
                } else {
                    //we already set the first line so make a CONC node
                    [subLines addObject:@[levelString,
                                         concString,
                                         attributedString(bite, GCValueAttributeName, bite)]];
                }
                
                firstPass = NO;
            }
            
            [subLines addObject:@[levelString,
                                 concString,
                                 attributedString(leftover, GCValueAttributeName, leftover)]];
        }
    }
    
    *outInitial = initial;
    *outSubLines = [subLines copy];
    
    //NSLog(@"outInitial: %@", *outInitial);
    //NSLog(@"outSubLines: %@", *outSubLines);
}

static inline NSAttributedString * joinedAttributedString(NSArray *components) {
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
    
    for (NSAttributedString *component in components) {
        [result appendAttributedString:component];
        [result appendAttributedString:space];
    }
    
    [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    
    return result;
}

- (NSArray *)attributedGedcomLinesAtLevel:(int) level
{
	NSMutableArray *gedLines = [NSMutableArray array];
    
    NSString *firstLine = nil;
    NSArray *subLineNodes = nil;
    
    NSString *gedVal = self.gedValue;
    if (![gedVal hasPrefix:@"@"]) { // xrefs always start with @
        gedVal = [gedVal stringByReplacingOccurrencesOfString:@"@" withString:@"@@"]; // escape @-sign
    }
	
    contConcHelper(level, gedVal, &firstLine, &subLineNodes);
    
    NSMutableArray *lineComponents = [NSMutableArray array];
    
    NSString *levelString = [NSString stringWithFormat:@"%d", level];
    
    [lineComponents addObject:attributedString(levelString, GCLevelAttributeName, levelString)];
    
    if (self.xref && ![self.xref isEqualToString:@""]) {
        [lineComponents addObject:attributedString(self.xref, GCXrefAttributeName, self.xref)];
        [lineComponents addObject:attributedString(self.gedTag, GCTagAttributeName, self.gedTag)];
	} else {
        [lineComponents addObject:attributedString(self.gedTag, GCTagAttributeName, self.gedTag)];
        if (firstLine) {
            if ([firstLine hasPrefix:@"@"] && [firstLine hasSuffix:@"@"]) {
                [lineComponents addObject:attributedString(firstLine, GCLinkAttributeName, firstLine)];
            } else {
                [lineComponents addObject:[[NSAttributedString alloc] initWithString:firstLine]];
            }
        }
    }
    
    [gedLines addObject:joinedAttributedString(lineComponents)];
    
    if (self.xref && ![self.xref isEqualToString:@""] && firstLine) {
        NSMutableArray *lineComponents = [NSMutableArray array];
        
        NSString *levelString = [NSString stringWithFormat:@"%d", level+1];
        
        [lineComponents addObject:attributedString(levelString, GCLevelAttributeName, levelString)];
        
        [lineComponents addObject:attributedString(@"CONC", GCTagAttributeName, @"CONC")];
        
        [lineComponents addObject:[[NSAttributedString alloc] initWithString:firstLine]];
        
        [gedLines addObject:joinedAttributedString(lineComponents)];
    }
    
    for (NSArray *subLine in subLineNodes) {
        [gedLines addObject:joinedAttributedString(subLine)];
    }
    
	for (id subNode in self.subNodes ) {
		[gedLines addObjectsFromArray:[subNode attributedGedcomLinesAtLevel:level+1]];
	}
	
	return gedLines;
}

- (NSArray *)gedcomLines
{
	NSMutableArray *lines = [NSMutableArray array];
    
    for (NSAttributedString *line in [self attributedGedcomLinesAtLevel:0]) {
        [lines addObject:[line string]];
    }
    
    return lines;
}

- (NSString *)gedcomString
{
	return [self.gedcomLines componentsJoinedByString:self.lineSeparator];
}

- (NSAttributedString *)attributedGedcomString
{
    NSMutableAttributedString *lines = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *lineFeed = [[NSAttributedString alloc] initWithString:self.lineSeparator];
    
    for (NSAttributedString *line in [self attributedGedcomLinesAtLevel:0]) {
        [lines appendAttributedString:line];
        [lines appendAttributedString:lineFeed];
    }
    
    [lines addAttribute:NSFontAttributeName value:[NSFont userFixedPitchFontOfSize:12.0f] range:NSMakeRange(0, [lines length])];
    
	return lines;
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForKey:(NSString *)key
{
    BOOL isTagKey = [[key uppercaseString] isEqualToString:key] && ([key length] == 4 || [key length] == 3 || [key hasPrefix:@"_"]);
    
    if (isTagKey) {
        NSMutableArray *subNodes = [NSMutableArray array];
        
        for (GCNode *subNode in self.subNodes) {
            if ([subNode.gedTag isEqualTo:key]) {
                [subNodes addObject:subNode];
            }
        }
        
        return [subNodes copy];
	} else {
        return [super valueForKey:key];
	}
}

#pragma mark Subscript accessors

- (id)objectForKeyedSubscript:(id)key
{
    return [self valueForKey:key];
}

#pragma mark Adding subnodes

- (void)addSubNode:(GCNode *)node
{
	NSParameterAssert(self != node);
    
	[_subNodes addObject:node];
	[node setParent:self];
}

#pragma mark Comparison

- (NSSet *)allSubTags
{
    NSMutableSet *subTags = [NSMutableSet set];
    
    for (GCNode *subNode in self.subNodes) {
        [subTags addObject:subNode.gedTag];
    }
    
    return [subTags copy];
}

- (BOOL)isEquivalentTo:(GCNode *)other
{
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    //NSLog(@"Comparing %@ with %@", a.gedcomString, b.gedcomString);
    
    if (![self.gedTag isEqualToString:other.gedTag])
        return NO;
    if ((self.gedValue && ![self.gedValue isEqualToString:other.gedValue]) || (other.gedValue && ![other.gedValue isEqualToString:self.gedValue]))
        return NO;
    if ((self.xref && ![self.xref isEqualToString:other.xref]) || (other.xref && ![other.xref isEqualToString:self.xref]))
        return NO;
    
    NSSet *subTagIntersection = [self.allSubTags setByAddingObjectsFromSet:other.allSubTags];
    
    //NSLog(@"subTagIntersection: %@", subTagIntersection);
    
    for (NSString *tag in subTagIntersection) {
        NSArray *subNodesA = self[tag];
        NSArray *subNodesB = other[tag];
        
        if ([subNodesA count] != [subNodesB count]) {
            return NO; // the number of subnodes in A & B for the tag don't match
        } else {
            NSMutableArray *leftoverA = [subNodesA mutableCopy];
            NSMutableArray *leftoverB = [subNodesB mutableCopy];
            
            for (GCNode *nodeA in subNodesA) {
                GCNode *matchingNodeA = nil;
                GCNode *matchingNodeB = nil;
                
                for (GCNode *nodeB in subNodesB) {
                    if ([nodeA isEquivalentTo:nodeB]) {
                        matchingNodeA = nodeA;
                        matchingNodeB = nodeB;
                        break;
                    }
                }
                
                if (matchingNodeA) {
                    [leftoverA removeObject:matchingNodeA];
                    [leftoverB removeObject:matchingNodeB];
                }
            }
            
            if ([leftoverA count] != 0) {
                return NO; // there are nodes left in A which don't have a match in B
            }
        }
    }
    
    return YES;
}

/*

- (BOOL)isEqual:(GCNode *)other
{
    if (![self.gedTag isEqualToString:[other gedTag]]) {
        return NO;
    }
    
    if (self.gedValue && ![self.gedValue isEqualToString:[other gedValue]]) {
        return NO;
    }
    
    if (self.xref && ![self.xref isEqualToString:[other xref]]) {
        return NO;
    }
    
    if (![[self.subNodes set] isEqualToSet:[[other subNodes] set]]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.gedTag hash] + [self.xref hash] + [self.gedValue hash] + [[self.subNodes set] hash];
}
*/

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"[GCNode tag: %@ xref: %@ value: %@ (subNodes: %@)]", self.gedTag, self.xref, self.gedValue, self.subNodes];
}
//COV_NF_END

#pragma mark NSCoding conformance

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_gedTag forKey:@"gedTag"];
    [encoder encodeObject:_gedValue forKey:@"gedValue"];
    [encoder encodeObject:_xref forKey:@"xref"];
    [encoder encodeObject:_lineSeparator forKey:@"lineSeparator"];
    [encoder encodeObject:_subNodes forKey:@"subNodes"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
    
    if (self) {
        _gedTag = [decoder decodeObjectForKey:@"gedTag"];
        _gedValue = [decoder decodeObjectForKey:@"gedValue"];
        _xref = [decoder decodeObjectForKey:@"xref"];
        _lineSeparator = [decoder decodeObjectForKey:@"lineSeparator"];
        _subNodes = [decoder decodeObjectForKey:@"subNodes"];
	}
    
    return self;
}

#pragma mark NSCopying conformance

- (id)copyWithZone:(NSZone *)zone
{
    GCNode *copy = [[GCNode allocWithZone:zone] initWithTag:self.gedTag 
                                                      value:self.gedValue 
                                                       xref:self.xref 
                                                   subNodes:self.subNodes];
    
    [copy setValue:self.lineSeparator forKey:@"lineSeparator"];
    
    return copy;
}

#pragma mark NSMutableCopying conformance

- (id)mutableCopyWithZone:(NSZone *)zone
{
    GCMutableNode *copy = [[GCMutableNode allocWithZone:zone] initWithTag:self.gedTag 
                                                                    value:self.gedValue 
                                                                     xref:self.xref 
                                                                 subNodes:nil];
    
    [copy setValue:self.lineSeparator forKey:@"lineSeparator"];
    
    for (id subNode in _subNodes) {
        [copy addSubNode:[subNode mutableCopy]];
    }
    
    return copy;
}

#pragma mark Objective-C properties

- (BOOL)valueIsXref
{
    return _gedValue != nil && [_gedValue hasSuffix:@"@"] && [_gedValue hasPrefix:@"@"];
}

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

+ (id)nodeWithTag:(NSString *)tag value:(NSString *)value subNodes:(NSArray *)subNodes
{
    return [[self alloc] initWithTag:tag value:value xref:nil subNodes:subNodes];
}

+ (id)nodeWithTag:(NSString *)tag xref:(NSString *)xref subNodes:(NSArray *)subNodes
{
    return [[self alloc] initWithTag:tag value:nil xref:xref subNodes:subNodes];
}

@end

NSString *GCLevelAttributeName = @"GCLevelAttributeName";
NSString *GCXrefAttributeName = @"GCXrefAttributeName";
NSString *GCTagAttributeName = @"GCTagAttributeName";
NSString *GCValueAttributeName = @"GCValueAttributeName";
NSString *GCLinkAttributeName = @"GCLinkAttributeName";
