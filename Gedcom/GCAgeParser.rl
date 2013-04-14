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

%%{
    machine age;
	
	action log {
		NSLog(@"%p log: %c", fpc, fc);
	}
	
	action tag {
		tag = fpc - data;
		//NSLog(@"%p     TAG: %d", fpc, tag);
	}
	
	action number {
		long len = (fpc - data) - tag;
		currentNumber = [[[NSString alloc] initWithBytes:fpc-len length:len encoding:NSUTF8StringEncoding] integerValue];
		//NSLog(@"%p num: %d", fpc, number);
	}
	
	action string {
		long len = (fpc - data) - tag;
		currentString = [[NSString alloc] initWithBytes:fpc-len length:len encoding:NSUTF8StringEncoding];
		//NSLog(@"%p string: %@", fpc, string);
	}
	
	action saveDays {
        [currentAgeComponents setDay:currentNumber];
		//NSLog(@"%p saveDays: %d", fpc, currentNumber);
	}
	
	action saveMonths {
        [currentAgeComponents setMonth:currentNumber];
		//NSLog(@"%p saveMonths: %d", fpc, currentNumber);
	}
	
	action saveYears {
        [currentAgeComponents setYear:currentNumber];
		//NSLog(@"%p saveYears: %d", fpc, currentNumber);
	}
    
    action saveSimpleAge {
        age = [GCAge ageWithSimpleAge:currentAgeComponents qualifier:qualifier];
    }
	
	action saveKeyword {
		age = [GCAge ageWithAgeKeyword:currentString qualifier:qualifier];
	}
	
	action lessThan {
		qualifier = GCAgeLessThan;
		//NSLog(@"%p lessThan", fpc);
	}
	
	action greaterThan {
		qualifier = GCAgeGreaterThan;
		//NSLog(@"%p greaterThan", fpc);
	}
	
	action finish {
		//NSLog(@"%p finish.", fpc);
		finished = YES;
	}
	
	number					= digit+ >tag %number;
	years					= number 'y' %saveYears;
	months					= number 'm' %saveMonths;
	days					= number 'd' %saveDays;
	
	simpleAge				= ( ( years? ' '? months? ' '? days? ) & ascii+ ) %saveSimpleAge;
	
	ageKeyword				= ( ( 'INFANT' | 'STILLBORN' | 'CHILD' ) >tag %string ) %saveKeyword;
    
	lessThan				= '<' %lessThan;
	greaterThan				= '>' %greaterThan;
	qualifier				= ( lessThan | greaterThan );
	
	main				   := ( qualifier ' '? )? ( simpleAge | ageKeyword ) %/finish;
    
}%%

%% write data;

@implementation GCAgeParser

__strong static id _sharedAgeParser = nil;

+ (void)initialize
{
    _sharedAgeParser = [[self alloc] init];
}

+ (id)sharedAgeParser
{
    return _sharedAgeParser;
}

- (GCAge *)parseGedcom:(NSString *)str
{
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
    const char *pe = p + [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char *eof = pe;
    
    %% write init;
    %% write exec;
    
    if (!finished) {
        age = nil;
    }
    
    if (age == nil) {
        age = [GCAge ageWithInvalidAgeString:str];
    }
    
    return age;
}

@end