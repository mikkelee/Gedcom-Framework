//
//  GCNodeParser.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 05/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCNodeParser.h"
#import "GCMutableNode.h"
#import "GCNodeParserDelegate.h"

static NSString *concSeparator = @"\u2060";

@implementation GCNodeParser

+ (id)sharedParser
{
    static dispatch_once_t predParser = 0;
    __strong static id _nodeParser = nil;
    dispatch_once(&predParser, ^{
        _nodeParser = [[self alloc] init];
    });
    return _nodeParser;
}

- (BOOL)parseString:(id)gedString error:(NSError *__autoreleasing *)error
{
    @synchronized(self) {
        __block NSUInteger nodeCount = 0;
        
        if ([gedString isKindOfClass:[NSAttributedString class]]) {
            gedString = [gedString string];
        }
        
        NSParameterAssert([gedString isKindOfClass:[NSString class]]);
        
        __block int currentLevel = 0;
        __block GCMutableNode *currentNode = nil;
        __block GCMutableNode *currentRoot = nil;
        
#ifdef DEBUGLEVEL
        clock_t start, end;
        double elapsed;
        start = clock();
        //NSLog(@"Began parsing gedcom.");
#endif
        
        NSRegularExpression *levelXrefTagValueRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d) (?:(\\@[A-Z_]+\\d*\\@) )?([A-Z]{3,4}[0-9]?|_[A-Z][A-Z0-9]*)(?: (.*))?$"
                                                                                                options:kNilOptions
                                                                                                  error:nil];
        
        [gedString enumerateLinesUsingBlock:^(NSString *gLine, BOOL *stop) {
            if ([gLine isEqualToString:@""]) {
                return;
            }
            
            int level = -1;
            GCMutableNode* node = nil;
            
            NSRange range = NSMakeRange(0, [gLine length]);
            NSTextCheckingResult *match = [levelXrefTagValueRegex firstMatchInString:gLine options:kNilOptions range:range];
            
            //NSLog(@"gLine: %@", gLine);
            
            if (match) {
                GCMutableNode *parent = nil;
                
                level = [[gLine substringWithRange:[match rangeAtIndex:1]] intValue];
                
                if (level == 0) { //root
                    if (currentRoot) {
                        nodeCount++;
                        if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNode:)]) {
                            [_delegate parser:self didParseNode:[currentRoot copy]];
                        }
                    }
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
                
                if (xref) {
                    node = [GCMutableNode nodeWithTag:code
                                                 xref:xref];
                } else {
                    node = [GCMutableNode nodeWithTag:code
                                                value:val];
                }
                
                if (parent) {
                    [parent.mutableSubNodes addObject:node];
                } else {
                    currentRoot = node;
                }
                
                currentLevel = level;
                currentNode = node;
                /*
                NSLog(@"parent: %@", parent);
                NSLog(@"level: %d", level);
                NSLog(@"xref: %@", xref);
                NSLog(@"code: %@", code);
                NSLog(@"val: %@", val);
                NSLog(@"node: %@", node);
                NSLog(@"currentNode: %@", currentNode);
                NSLog(@"currentRoot: %@", currentRoot);*/
            } else {
                NSLog(@"Unable to create node from gedcom: '%@' -- will assume faulty linefeed and append to value of previous node: %@", gLine, currentNode);
                
                if (currentNode.gedValue == nil) {
                    currentNode.gedValue = gLine;
                } else {
                    currentNode.gedValue = [NSString stringWithFormat:@"%@\n%@", currentNode.gedValue, gLine];
                }
            }
        }];
        
        if (currentRoot) {
            nodeCount++;
            if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNode:)]) {
                [_delegate parser:self didParseNode:[currentRoot copy]];
            }
        }
        
#ifdef DEBUGLEVEL
        end = clock();
        elapsed = ((double) (end - start)) / CLOCKS_PER_SEC;
        NSLog(@"arrayOfNodesFromString - Time: %f seconds",elapsed);
#endif
        
        if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNodesWithCount:)]) {
            [_delegate parser:self didParseNodesWithCount:nodeCount];
        }
    }
    
    return YES;
}

@end

@interface _GCNodeParserConvenienceDelegate : NSObject <GCNodeParserDelegate>

@property NSArray *nodes;

@end

@implementation _GCNodeParserConvenienceDelegate {
    NSMutableArray *_nodes;
}

- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node
{
    if (!_nodes) {
        _nodes = [NSMutableArray array];
    }
    [_nodes addObject:node];
}

- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount
{
    NSParameterAssert(nodeCount == [_nodes count]);
}

@end

@implementation GCNodeParser (GCConvenienceMethods)

+ (NSArray*)arrayOfNodesFromString:(id)gedString
{
    _GCNodeParserConvenienceDelegate *delegate = [[_GCNodeParserConvenienceDelegate alloc] init];
    
    GCNodeParser *parser = [[GCNodeParser alloc] init];
    parser.delegate = delegate;
    
    BOOL succeeded = [parser parseString:gedString error:nil];
    
    if (succeeded) {
        return delegate.nodes;
    } else {
        return nil;
    }    
}

@end