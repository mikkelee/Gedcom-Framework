
#line 1 "GCAgeParser.rl"
/**

Ragel state machine for GEDCOM ages based on the 5.5 documentation.

	 AGE_AT_EVENT: = {Size=1:12} 
	 [ < | > | <NULL>] 
	 [ YYy MMm DDDd | YYy | MMm | DDDd | 
	 YYy MMm | YYy DDDd | MMm DDDd | 
	 CHILD | INFANT | STILLBORN ] 
	 ] 
	 Where : 
	 > = greater than indicated age 
	 < = less than indicated age 
	 y = a label indicating years 
	 m = a label indicating months 
	 d = a label indicating days 
	 YY = number of full years 
	 MM = number of months 
	 DDD = number of days 
	 CHILD = age < 8 years 
	 INFANT = age < 1 year 
	 STILLBORN = died just prior, at, or near birth, 0 years 

*/

#import "GCAge_internal.h"


#line 105 "GCAgeParser.rl"



#line 36 "GCAgeParser.m"
static const char _age_actions[] = {
	0, 1, 0, 1, 1, 1, 4, 1, 
	5, 1, 8, 1, 9, 2, 4, 0, 
	2, 5, 0, 2, 6, 10, 2, 8, 
	0, 2, 9, 0, 3, 2, 7, 10, 
	3, 3, 6, 10, 3, 4, 6, 10, 
	3, 5, 6, 10
};

static const char _age_key_offsets[] = {
	0, 0, 8, 11, 15, 20, 26, 27, 
	28, 29, 30, 31, 32, 33, 34, 35, 
	36, 37, 38, 39, 40, 41, 42, 43, 
	49, 52, 54, 54, 57, 60, 66
};

static const char _age_trans_keys[] = {
	32, 60, 62, 67, 73, 83, 48, 57, 
	100, 48, 57, 100, 109, 48, 57, 100, 
	109, 121, 48, 57, 32, 67, 73, 83, 
	48, 57, 72, 73, 76, 68, 78, 70, 
	65, 78, 84, 84, 73, 76, 76, 66, 
	79, 82, 78, 32, 67, 73, 83, 48, 
	57, 32, 48, 57, 48, 57, 32, 48, 
	57, 32, 48, 57, 32, 67, 73, 83, 
	48, 57, 0
};

static const char _age_single_lengths[] = {
	0, 6, 1, 2, 3, 4, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 4, 
	1, 0, 0, 1, 1, 4, 0
};

static const char _age_range_lengths[] = {
	0, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 1, 0, 1, 1, 1, 0
};

static const char _age_index_offsets[] = {
	0, 0, 8, 11, 15, 20, 26, 28, 
	30, 32, 34, 36, 38, 40, 42, 44, 
	46, 48, 50, 52, 54, 56, 58, 60, 
	66, 69, 71, 72, 75, 78, 84
};

static const char _age_trans_targs[] = {
	24, 5, 23, 6, 10, 15, 4, 0, 
	26, 2, 0, 26, 27, 3, 0, 26, 
	27, 28, 4, 0, 29, 6, 10, 15, 
	4, 0, 7, 0, 8, 0, 9, 0, 
	30, 0, 11, 0, 12, 0, 13, 0, 
	14, 0, 30, 0, 16, 0, 17, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 30, 0, 29, 6, 10, 15, 
	4, 0, 25, 3, 0, 2, 0, 0, 
	25, 2, 0, 24, 3, 0, 24, 6, 
	10, 15, 4, 0, 0, 0
};

static const char _age_trans_actions[] = {
	0, 0, 0, 1, 1, 1, 1, 0, 
	3, 0, 0, 3, 3, 0, 0, 3, 
	3, 3, 0, 0, 9, 22, 22, 22, 
	22, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 11, 25, 25, 25, 
	25, 0, 0, 1, 0, 1, 0, 0, 
	5, 13, 0, 7, 16, 0, 0, 1, 
	1, 1, 1, 0, 0, 0
};

static const char _age_eof_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	19, 19, 32, 36, 40, 19, 28
};

static const int age_start = 1;
static const int age_first_final = 24;
static const int age_error = 0;

static const int age_en_main = 1;


#line 108 "GCAgeParser.rl"

@implementation GCAgeParser {
	NSMutableDictionary *_cache;
}

+ (id)sharedAgeParser // fancy new ARC/GCD singleton!
{
    static dispatch_once_t predAgeParser = 0;
    __strong static id _sharedAgeParser = nil;
    dispatch_once(&predAgeParser, ^{
        _sharedAgeParser = [[self alloc] init];
    });
    return _sharedAgeParser;
}

- (GCAgeParser *)init
{
    self = [super init];
    
    if (self) {
        _cache = [NSMutableDictionary dictionary];
    }
	
	return self;
}

- (GCAge *)parseGedcom:(NSString *)str
{
    @synchronized(_cache) {
        if (_cache[str]) {
            //NSLog(@"Getting cached age for %@", str);
            return [_cache[str] copy];
        }
        
        GCAge *age = nil;
        NSDateComponents *currentAgeComponents = [[NSDateComponents alloc] init];
        [currentAgeComponents setYear:0];
        [currentAgeComponents setMonth:0];
        [currentAgeComponents setDay:0];
        GCAgeQualifier qualifier = GCAgeNoQualifier;
        long tag = 0;
        NSInteger currentNumber = 0;
        NSString *currentString = nil;
        BOOL finished = NO;
        
        int cs = 0;
        const char *data = [str UTF8String];
        const char *p = data;
        const char *pe = p + [str length];
        const char *eof = pe;
        
        
#line 181 "GCAgeParser.m"
	{
	cs = age_start;
	}

#line 160 "GCAgeParser.rl"
        
#line 188 "GCAgeParser.m"
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
	_keys = _age_trans_keys + _age_key_offsets[cs];
	_trans = _age_index_offsets[cs];

	_klen = _age_single_lengths[cs];
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

	_klen = _age_range_lengths[cs];
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
	cs = _age_trans_targs[_trans];

	if ( _age_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _age_actions + _age_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 35 "GCAgeParser.rl"
	{
		tag = p - data;
		//NSLog(@"%p     TAG: %d", fpc, tag);
	}
	break;
	case 1:
#line 40 "GCAgeParser.rl"
	{
		long len = (p - data) - tag;
		currentNumber = [[[NSString alloc] initWithBytes:p-len length:len encoding:NSUTF8StringEncoding] integerValue];
		//NSLog(@"%p num: %d", fpc, number);
	}
	break;
	case 4:
#line 57 "GCAgeParser.rl"
	{
        [currentAgeComponents setMonth:currentNumber];
		//NSLog(@"%p saveMonths: %d", fpc, currentNumber);
	}
	break;
	case 5:
#line 62 "GCAgeParser.rl"
	{
        [currentAgeComponents setYear:currentNumber];
		//NSLog(@"%p saveYears: %d", fpc, currentNumber);
	}
	break;
	case 8:
#line 75 "GCAgeParser.rl"
	{
		qualifier = GCAgeLessThan;
		//NSLog(@"%p lessThan", fpc);
	}
	break;
	case 9:
#line 80 "GCAgeParser.rl"
	{
		qualifier = GCAgeGreaterThan;
		//NSLog(@"%p greaterThan", fpc);
	}
	break;
#line 304 "GCAgeParser.m"
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
	const char *__acts = _age_actions + _age_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 2:
#line 46 "GCAgeParser.rl"
	{
		long len = (p - data) - tag;
		currentString = [[NSString alloc] initWithBytes:p-len length:len encoding:NSUTF8StringEncoding];
		//NSLog(@"%p string: %@", fpc, string);
	}
	break;
	case 3:
#line 52 "GCAgeParser.rl"
	{
        [currentAgeComponents setDay:currentNumber];
		//NSLog(@"%p saveDays: %d", fpc, currentNumber);
	}
	break;
	case 4:
#line 57 "GCAgeParser.rl"
	{
        [currentAgeComponents setMonth:currentNumber];
		//NSLog(@"%p saveMonths: %d", fpc, currentNumber);
	}
	break;
	case 5:
#line 62 "GCAgeParser.rl"
	{
        [currentAgeComponents setYear:currentNumber];
		//NSLog(@"%p saveYears: %d", fpc, currentNumber);
	}
	break;
	case 6:
#line 67 "GCAgeParser.rl"
	{
        age = [GCAge ageWithSimpleAge:currentAgeComponents qualifier:qualifier];
    }
	break;
	case 7:
#line 71 "GCAgeParser.rl"
	{
		age = [GCAge ageWithAgeKeyword:currentString qualifier:qualifier];
	}
	break;
	case 10:
#line 85 "GCAgeParser.rl"
	{
		//NSLog(@"%p finish.", fpc);
		finished = YES;
	}
	break;
#line 368 "GCAgeParser.m"
		}
	}
	}

	_out: {}
	}

#line 161 "GCAgeParser.rl"
        
        if (!finished) {
            age = nil;
        }
        
        if (age == nil) {
            age = [GCAge ageWithInvalidAgeString:str];
        }
        
        _cache[str] = age;
        
        return age;
    }
}

@end