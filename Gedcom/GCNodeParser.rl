/**

Ragel state machine for GEDCOM nodes based on the 5.5 documentation.

gedcom_line := 
level + delim + [xref_id + delim +] tag + [delim + line_value +] terminator 
level + delim + optional_xref_id + tag + delim + optional_line_value + terminator 

*/

#import "GCNodeParser.h"
#import "GCNodeParserDelegate.h"

#import "GCNode.h"

#import "GedcomErrors.h"

#define DEBUGLINECOUNT 84300

%%{
    machine nodeParser;
	
	action log {
		//if (lineCount > DEBUGLINECOUNT) NSLog(@"%p log: (%X) '%c'", fpc, fc, fc);
	}
    
	action tag {
		tag = fpc - data;
        //if (lineCount > DEBUGLINECOUNT) NSLog(@"%p     TAG: %ld", fpc, tag);
	}
	
	action number {
		long len = (fpc - data) - tag;
		currentNumber = [[[NSString alloc] initWithBytes:fpc-len length:len encoding:NSUTF8StringEncoding] intValue];
		//if (lineCount > DEBUGLINECOUNT) NSLog(@"%p num: %d", fpc, currentNumber);
	}
	
	action string {
		long len = (fpc - data) - tag;
		currentString = [[NSString alloc] initWithBytes:fpc-len length:len encoding:NSUTF8StringEncoding];
		//if (lineCount > DEBUGLINECOUNT) NSLog(@"%p string: %@", fpc, currentString);
	}
	
	action saveLevel {
        level = currentNumber;
	}
    
    action saveXref {
        xref = currentString;
    }
    
    action saveTagCode {
        code = currentString;
    }
    
    action saveValue {
        value = [currentString stringByReplacingOccurrencesOfString:@"@@" withString:@"@"]; // unescape at-sign
    }
	
	action saveNode {
        lineCount++;
        
        // CONT/CONC nodes are continuations of values from the previous node, so fold them up here:
        // TODO: refactor (use dict?)
        if ([code isEqualToString:@"CONT"]) {
            if (!currentNode.gedValue) {
                currentNode.gedValue = value;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@%@%@", currentNode.gedValue, @"\n", value ? value : @""];
            }
        } else if ([code isEqualToString:@"CONC"]) {
            if (!currentNode.gedValue) {
                currentNode.gedValue = value;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@%@%@", currentNode.gedValue, concSeparator, value ? value : @""];
            }
        } else {
            if (xref) {
                node = [GCNode nodeWithTag:code
                                      xref:xref];
            } else {
                node = [GCNode nodeWithTag:code
                                     value:value];
            }
                
            GCNode *parent = nil;

            if (level == 0) { //root
                if (currentRoot) {
                    nodeCount++;
                    if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNode:)]) {
                        [_delegate parser:self didParseNode:currentRoot];
                    }
                }
            } else { //find correct parent
                parent = currentNode;
                for (int i = currentLevel; i >= level; i--) {
                    parent = [parent parent];
                }
            }

            if (parent) {
                [parent.mutableSubNodes addObject:node];
            } else {
                currentRoot = node;
            }

            currentLevel = level;
            currentNode = node;
        }
                
        level = -1;
        xref = nil;
        code = nil;
        value = nil;
	}
	
	action finish {
        if (currentRoot) {
            nodeCount++;
            if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNode:)]) {
                [_delegate parser:self didParseNode:currentRoot];
            }
        }
		didFinish = YES;
	}
    
    delim                   = ' ';
    terminator              = ( '\r' | '\n' )+;
    
    keyword                 = ( alpha ( alnum | '_' )+ );

    level                   = ( digit+ >tag %number ) %saveLevel;
    xref                    = ( ( '@' keyword '@' ) >tag %string ) %saveXref;
    tagCode                 = ( ( '_'? keyword ) >tag %string ) %saveTagCode;
    value                   = ( ( extend - terminator )+ >tag %string ) %saveValue;

    contents                = ( ( xref delim tagCode ) | ( tagCode delim value ) | ( tagCode delim? ) );

    node                    = ( level delim contents terminator ) %saveNode;
    
    main                   := ( node+ ) %/finish;
    
}%%

%% write data;

@implementation GCNodeParser

__strong static id _sharedNodeParser = nil;

+ (void)initialize
{
    _sharedNodeParser = [[self alloc] init];
}

+ (id)sharedNodeParser
{
    return _sharedNodeParser;
}

- (BOOL)parseString:(id)gedString error:(NSError *__autoreleasing *)error
{
    @synchronized(self) {
        if ([gedString isKindOfClass:[NSAttributedString class]]) {
            gedString = [gedString string];
        }
        
        NSParameterAssert([gedString isKindOfClass:[NSString class]]);
        
        gedString = [gedString stringByAppendingString:@"\n"];

        NSUInteger nodeCount = 0;
        NSUInteger lineCount = 0;
        int currentLevel = 0;
        GCNode *currentNode = nil;
        GCNode *currentRoot = nil;
        
        long tag = 0;
        int currentNumber = 0;
        NSString *currentString = nil;
        
        int level = -1;
        NSString *xref = nil;
        NSString *code = nil;
        NSString *value = nil;
        GCNode* node = nil;
        
        BOOL didFinish = NO;

        int cs = 0;
        const char *data = [gedString UTF8String];
        const char *p = data;
        const char *pe = p + [gedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        const char *eof = pe;
        
#ifdef DEBUGLEVEL
        clock_t start, end;
        double elapsed;
        start = clock();
        //NSLog(@"Began parsing gedcom.");
#endif
        
        %% write init;
        %% write exec;
                
#ifdef DEBUGLEVEL
        end = clock();
        elapsed = ((double) (end - start)) / CLOCKS_PER_SEC;
        NSLog(@"parsed %ld nodes in %ld lines - Time: %f seconds", nodeCount, lineCount, elapsed);
#endif
        
        if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNodesWithCount:)]) {
            [_delegate parser:self didParseNodesWithCount:nodeCount];
        }
        
        if (!didFinish) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:GCErrorDomain
                                             code:GCNodeParsingError
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Parser stopped at node #%ld (line %ld)", nodeCount, lineCount], NSAffectedObjectsErrorKey: currentNode}];
            }
        }
        
        return didFinish;
    }
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
    //NSLog(@"%p got node: %@", self, node);
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
    
    NSError *error = nil;
    BOOL succeeded = [parser parseString:gedString error:&error];
    
    if (succeeded) {
        return delegate.nodes;
    } else {
        NSLog(@"error: %@", error);
        return nil;
    }    
}

@end