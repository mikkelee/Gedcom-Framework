
#line 1 "GCNodeParser.rl"
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


#line 137 "GCNodeParser.rl"



#line 26 "GCNodeParser.m"
static const char _node_actions[] = {
	0, 1, 0, 2, 1, 3, 2, 2, 
	4, 2, 2, 5, 2, 2, 6, 2, 
	7, 0, 2, 7, 8
};

static const char _node_key_offsets[] = {
	0, 0, 2, 5, 11, 15, 22, 30, 
	31, 36, 43, 52, 56, 63, 73, 75, 
	79, 83
};

static const char _node_trans_keys[] = {
	48, 57, 32, 48, 57, 64, 95, 65, 
	90, 97, 122, 65, 90, 97, 122, 95, 
	48, 57, 65, 90, 97, 122, 64, 95, 
	48, 57, 65, 90, 97, 122, 32, 95, 
	65, 90, 97, 122, 95, 48, 57, 65, 
	90, 97, 122, 10, 13, 95, 48, 57, 
	65, 90, 97, 122, 65, 90, 97, 122, 
	95, 48, 57, 65, 90, 97, 122, 10, 
	13, 32, 95, 48, 57, 65, 90, 97, 
	122, 32, 126, 10, 13, 32, 126, 65, 
	90, 97, 122, 10, 13, 48, 57, 0
};

static const char _node_single_lengths[] = {
	0, 0, 1, 2, 0, 1, 2, 1, 
	1, 1, 3, 0, 1, 4, 0, 2, 
	0, 2
};

static const char _node_range_lengths[] = {
	0, 1, 1, 2, 2, 3, 3, 0, 
	2, 3, 3, 2, 3, 3, 1, 1, 
	2, 1
};

static const char _node_index_offsets[] = {
	0, 0, 2, 5, 10, 13, 18, 24, 
	26, 30, 35, 42, 45, 50, 58, 60, 
	64, 67
};

static const char _node_indicies[] = {
	0, 1, 2, 3, 1, 4, 6, 5, 
	5, 1, 7, 7, 1, 8, 8, 8, 
	8, 1, 9, 8, 8, 8, 8, 1, 
	10, 1, 12, 11, 11, 1, 13, 13, 
	13, 13, 1, 14, 14, 13, 13, 13, 
	13, 1, 15, 15, 1, 16, 16, 16, 
	16, 1, 14, 14, 17, 16, 16, 16, 
	16, 1, 18, 1, 19, 19, 20, 1, 
	21, 21, 1, 22, 22, 23, 1, 0
};

static const char _node_trans_targs[] = {
	2, 0, 3, 2, 4, 12, 16, 5, 
	6, 7, 8, 9, 11, 10, 17, 9, 
	13, 14, 15, 17, 15, 12, 17, 2
};

static const char _node_trans_actions[] = {
	1, 0, 3, 0, 1, 1, 1, 0, 
	0, 0, 6, 1, 1, 0, 9, 0, 
	0, 9, 1, 12, 0, 0, 0, 15
};

static const char _node_eof_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 18
};

static const int node_start = 1;
static const int node_first_final = 17;
static const int node_error = 0;

static const int node_en_main = 1;


#line 140 "GCNodeParser.rl"

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
        
#ifdef DEBUGLEVEL
        clock_t start, end;
        double elapsed;
        start = clock();
        //NSLog(@"Began parsing gedcom.");
#endif

        long tag = 0;
        int currentNumber = 0;
        NSString *currentString = nil;
        BOOL didFinish = NO;
        
        int level = -1;
        NSString *xref = nil;
        NSString *code = nil;
        NSString *value = nil;
        GCNode* node = nil;

        int cs = 0;
        const char *data = [gedString UTF8String];
        const char *p = data;
        const char *pe = p + [gedString length];
        const char *eof = pe;
        
        
#line 166 "GCNodeParser.m"
	{
	cs = node_start;
	}

#line 197 "GCNodeParser.rl"
        
#line 173 "GCNodeParser.m"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _node_trans_keys + _node_key_offsets[cs];
	_trans = _node_index_offsets[cs];

	_klen = _node_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (unsigned int)(_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _node_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += (unsigned int)((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	_trans = _node_indicies[_trans];
	cs = _node_trans_targs[_trans];

	if ( _node_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _node_actions + _node_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 25 "GCNodeParser.rl"
	{
		tag = p - data;
		//NSLog(@"%p     TAG: %d", fpc, tag);
	}
	break;
	case 1:
#line 30 "GCNodeParser.rl"
	{
		long len = (p - data) - tag;
		currentNumber = [[[NSString alloc] initWithBytes:p-len length:len encoding:NSUTF8StringEncoding] intValue];
		//NSLog(@"%p num: %d", fpc, currentNumber);
	}
	break;
	case 2:
#line 36 "GCNodeParser.rl"
	{
		long len = (p - data) - tag;
		currentString = [[NSString alloc] initWithBytes:p-len length:len encoding:NSUTF8StringEncoding];
		//NSLog(@"%p string: %@", fpc, currentString);
	}
	break;
	case 3:
#line 42 "GCNodeParser.rl"
	{
        level = currentNumber;
		//NSLog(@"%p saveLevel: %d", fpc, currentNumber);
	}
	break;
	case 4:
#line 47 "GCNodeParser.rl"
	{
        xref = currentString;
    }
	break;
	case 5:
#line 51 "GCNodeParser.rl"
	{
        code = currentString;
    }
	break;
	case 6:
#line 55 "GCNodeParser.rl"
	{
        value = [currentString stringByReplacingOccurrencesOfString:@"@@" withString:@"@"]; // unescape at-sign
    }
	break;
	case 7:
#line 59 "GCNodeParser.rl"
	{
        lineCount++;

        // CONT/CONC nodes are continuations of values from the previous node, so fold them up here:
        if ([code isEqualToString:@"CONT"]) {
            if (currentNode.gedValue == nil) {
                currentNode.gedValue = value;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@\n%@", currentNode.gedValue, value];
            }
        } else if ([code isEqualToString:@"CONC"]) {
            if (currentNode.gedValue == nil) {
                currentNode.gedValue = value;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@%@%@", currentNode.gedValue, concSeparator, value];
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
	break;
#line 354 "GCNodeParser.m"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	const char *__acts = _node_actions + _node_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 7:
#line 59 "GCNodeParser.rl"
	{
        lineCount++;

        // CONT/CONC nodes are continuations of values from the previous node, so fold them up here:
        if ([code isEqualToString:@"CONT"]) {
            if (currentNode.gedValue == nil) {
                currentNode.gedValue = value;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@\n%@", currentNode.gedValue, value];
            }
        } else if ([code isEqualToString:@"CONC"]) {
            if (currentNode.gedValue == nil) {
                currentNode.gedValue = value;
            } else {
                currentNode.gedValue = [NSString stringWithFormat:@"%@%@%@", currentNode.gedValue, concSeparator, value];
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
	break;
	case 8:
#line 116 "GCNodeParser.rl"
	{
		//NSLog(@"%p finish.", fpc);
		didFinish = YES;
	}
	break;
#line 436 "GCNodeParser.m"
		}
	}
	}

	_out: {}
	}

#line 198 "GCNodeParser.rl"
        
        // TODO fix order so this is unneeded.
        if (currentRoot) {
            nodeCount++;
            if (_delegate && [_delegate respondsToSelector:@selector(parser:didParseNode:)]) {
                [_delegate parser:self didParseNode:currentRoot];
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
        
        if (!didFinish) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:GCErrorDomain
                                             code:GCNodeParsingError
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Parser stopped at node #%ld (line %ld): %@", nodeCount, lineCount, currentNode], NSAffectedObjectsErrorKey: currentNode}];
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