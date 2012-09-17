/**

Ragel state machine for GEDCOM dates based on the 5.5 documentation.

	 DATE: = {Size=4:35} 
	 [ <DATE_CALENDAR_ESCAPE> | <NULL>] 
	 <DATE_CALENDAR> 
	 
	 DATE_APPROXIMATED: = {Size=4:35} 
	 [ 
	 ABT <DATE> | 
	 CAL <DATE> | 
	 EST <DATE> 
	 ] 
	 
	 DATE_CALENDAR: = {Size=4:35} 
	 [ <DATE_GREG> | <DATE_JULN> | <DATE_HEBR> | <DATE_FREN> | 
	 <DATE_FUTURE> ] 
	 
	 DATE_CALENDAR_ESCAPE: = {Size=4:15} 
	 [ @#DHEBREW@ | @#DROMAN@ | @#DFRENCH R@ | @#DGREGORIAN@ | 
	 @#DJULIAN@ | @#DUNKNOWN@ ] 
	 
	 DATE_EXACT: = {Size=10:11} 
	 <DAY> <MONTH> <YEAR_GREG> 
	 
	 DATE_FREN: = {Size=4:35} 
	 [ <YEAR> | <MONTH_FREN> <YEAR> | <DAY> <MONTH_FREN> <YEAR> ] 
	 See <MONTH_FREN> 
	 
	 DATE_GREG: = {Size=4:35} 
	 [ <YEAR_GREG> | <MONTH> <YEAR_GREG> | <DAY> <MONTH> <YEAR_GREG> ] 
	 See <YEAR_GREG>. 
	 
	 DATE_HEBR: = {Size=4:35} 
	 [ <YEAR> | <MONTH_HEBR> <YEAR> | <DAY> <MONTH_HEBR> <YEAR> ] 
	 See <MONTH_HEBR>. 
	 
	 DATE_JULN: = {Size=4:35} 
	 [ <YEAR> | <MONTH> <YEAR> | <DAY> <MONTH> <YEAR> ] 
	 
	 DATE_LDS_ORD: = {Size=4:35} 
	 <DATE_VALUE> 
	 
	 DATE_PERIOD: = {Size=7:35} 
	 [ 
	 FROM <DATE> | 
	 TO <DATE> | 
	 FROM <DATE> TO <DATE> 
	 ] 
	 
	 DATE_PHRASE: = {Size=1:35} 
	 (<TEXT>) 
	 
	 DATE_RANGE: = {Size=8:35} 
	 [ 
	 BEF <DATE> | 
	 AFT <DATE> | 
	 BET <DATE> AND <DATE> 
	 ] 
	 
	 DATE_VALUE: = {Size=1:35} 
	 [ 
	 <DATE> | 
	 <DATE_PERIOD> | 
	 <DATE_RANGE> 
	 <DATE_APPROXIMATED> | 
	 INT <DATE> (<DATE_PHRASE>) | 
	 (<DATE_PHRASE>) 
	 ] 
	 
	 DAY: = {Size=1:2} 
	 dd

	 MONTH: = {Size=3} 
	 [ JAN | FEB | MAR | APR | MAY | JUN | 
	 JUL | AUG | SEP | OCT | NOV | DEC ] 
	 
	 MONTH_FREN: = {Size=4} 
	 [ VEND | BRUM | FRIM | NIVO | PLUV | VENT | GERM | 
	 FLOR | PRAI | MESS | THER | FRUC | COMP ] 
	 
	 MONTH_HEBR: = {Size=3} 
	 [ TSH | CSH | KSL | TVT | SHV | ADR | ADS | 
	 NSN | IYR | SVN | TMZ | AAV | ELL ] 
	 
	 YEAR_GREG: = {Size=3:7} 
	 [ <NUMBER> | <NUMBER>/<DIGIT><DIGIT> ] 

*/

#import "GCDate_internal.h"

%%{
	machine date;
	
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
	
	action saveDay {
        [currentDateComponents setDay:currentNumber];
		//NSLog(@"%p saveDays: %d", fpc, currentNumber);
	}
	
	action saveMonthNumeral {
        [currentDateComponents setMonth:currentNumber];
		//NSLog(@"%p saveMonthNumeral: %d", fpc, currentNumber);
	}
	
	action saveMonthWord {
        NSArray *monthNames = @[ @"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC" ];
        [currentDateComponents setMonth:[monthNames indexOfObject:currentString]+1];
		//NSLog(@"%p saveMonthWord: %d", fpc, currentNumber);
	}
	
	action saveMonthFren {
        NSArray *monthNames = @[ @"VEND", @"BRUM", @"FRIM", @"NIVO", @"PLUV", @"VENT", @"GERM", @"FLOR", @"PRAI", @"MESS", @"THER", @"FRUC", @"COMP" ];
        [currentDateComponents setMonth:[monthNames indexOfObject:currentString]+1];
		//NSLog(@"%p saveMonthFren: %d", fpc, currentNumber);
	}
	
	action saveMonthHebr {
        NSArray *monthNames = @[ @"TSH", @"CSH", @"KSL", @"TVT", @"SHV", @"ADR", @"ADS", @"NSN", @"IYR", @"SVN", @"TMZ", @"AAV", @"ELL" ];
        [currentDateComponents setMonth:[monthNames indexOfObject:currentString]+1];
		//NSLog(@"%p saveMonthHebr: %d", fpc, currentNumber);
	}
	
	action saveYear {
        [currentDateComponents setYear:currentNumber];
		//NSLog(@"%p saveYears: %d", fpc, currentNumber);
	}
    
    action setCalendarGregorian {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    action setCalendarJulian {
        //TODO
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:nil];
    }
    
    action setCalendarHebrew {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar];
    }
    
    action setCalendarFrenchRevolutionary {
        //TODO
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:nil];
    }
    
    action saveApproximationQualifier {
        approximationQualifier = currentString;
    }
    
    action saveDatePart {
		//NSLog(@"%p saveDatePart.", fpc);
        previousDate = currentDate;
        currentDateComponents = [[NSDateComponents alloc] init];
        [currentDateComponents setYear:0];
        [currentDateComponents setMonth:0];
        [currentDateComponents setDay:0];
        currentDate = nil;
    }
    
    action saveDateSimple {
		//NSLog(@"%p saveDateSimple.", fpc);
        currentDate = [GCDate dateWithSimpleDate:currentDateComponents withCalendar:calendar];
    }
    
    action saveDateApproximate {
		//NSLog(@"%p saveDateApproximate.", fpc);
        currentDate = [GCDate dateWithApproximateDate:currentDate withType:approximationQualifier];
    }
    
    action saveDatePhrase {
		//NSLog(@"%p saveDatePhrase.", fpc);
        currentDate = [GCDate dateWithPhrase:currentString];
    }
    
    action saveDateInterpreted {
		//NSLog(@"%p saveDateInterpreted.", fpc);
        currentDate = [GCDate dateWithInterpretedDate:previousDate withPhrase:currentDate];
    }
    
    action saveDateRange {
		//NSLog(@"%p saveDateRange.", fpc);
        currentDate = [GCDate dateWithRangeFrom:previousDate to:currentDate];
    }
    
    action saveDatePeriod {
		//NSLog(@"%p saveDatePeriod.", fpc);
        currentDate = [GCDate dateWithPeriodFrom:previousDate to:currentDate];
    }
    
	action finish {
		//NSLog(@"%p finish.", fpc);
        date = currentDate;
		finished = YES;
	}
	
	day					= ( digit digit? ) >tag %number %saveDay;

	monthWord			= (	'JAN' | 'FEB' | 'MAR' | 'APR' | 'MAY' | 'JUN' | 
							'JUL' | 'AUG' | 'SEP' | 'OCT' | 'NOV' | 'DEC') >tag %string %saveMonthWord;
	monthNumeral		= ( digit digit? ) >tag %number %saveMonthNumeral;
	month				= ( monthWord | monthNumeral );

	monthFren			= (	'VEND' | 'BRUM' | 'FRIM' | 'NIVO' | 'PLUV' | 
							'VENT' | 'GERM' | 'FLOR' | 'PRAI' | 'MESS' | 
							'THER' | 'FRUC' | 'COMP' ) >tag %string %saveMonthFren;
	monthHebr			= (	'TSH' | 'CSH' | 'KSL' | 'TVT' | 'SHV' | 'ADR' | 
							'ADS' | 'NSN' | 'IYR' | 'SVN' | 'TMZ' | 'AAV' | 
							'ELL' ) >tag %string %saveMonthHebr;
	year 				= ( digit digit digit digit? ) >tag %number %saveYear;
	yearGreg			= ( year | year '/' digit digit );
	
    sep                 = ( ' ' | '/' | '-' );
	
	dateGreg			= ( yearGreg | (monthWord sep yearGreg) | (day sep month sep yearGreg) ) %setCalendarGregorian;
	dateJuln			= ( year | (monthWord sep year) | (day sep month sep year) ) %setCalendarJulian;
	dateHebr			= ( year | (monthHebr sep year) | (day sep monthHebr sep year) ) %setCalendarHebrew;
	dateFren			= ( year | (monthFren sep year) | (day sep monthFren sep year) ) %setCalendarFrenchRevolutionary;
	
	dateSimple			= ( '@#DGREGORIAN@ ' dateGreg |
							'@#DJULIAN@ ' dateJuln | 
							'@#DHEBREW@ ' dateHebr | 
							'@#DFRENCH R@ ' dateFren | 
							dateGreg ) %saveDateSimple;
	
	datePhrase			= ( '(' any* >tag %string %saveDatePhrase ')' );
	
	dateInterpreted		= ( 'INT ' dateSimple %saveDatePart ' ' datePhrase ) %saveDateInterpreted;
	
	dateApproximated	= ( ('ABT' | 'CAL' | 'EST') >tag %string %saveApproximationQualifier ' ' dateSimple ) %saveDateApproximate;
	
	dateRange			= ( ('BET ' dateSimple %saveDatePart ' AND ' dateSimple)
						  | ('BEF ' dateSimple %saveDatePart)
						  | ('AFT ' dateSimple)
                          ) %saveDateRange ;
	
	datePeriod			= ( ('FROM ' dateSimple %saveDatePart ' TO ' dateSimple)
						  | ('FROM ' dateSimple %saveDatePart)
						  | ('TO ' dateSimple)
                          ) %saveDatePeriod ;
	
	main               := ( dateSimple  
						  | datePeriod
						  | dateRange
						  | dateApproximated
						  | dateInterpreted
						  | datePhrase
                          )  %/finish;
    
}%%

%% write data;

@implementation GCDateParser {
	NSMutableDictionary *_cache;
}

+ (id)sharedDateParser // fancy new ARC/GCD singleton!
{
    static dispatch_once_t predDateParser = 0;
    __strong static id _sharedDateParser = nil;
    dispatch_once(&predDateParser, ^{
        _sharedDateParser = [[self alloc] init];
    });
    return _sharedDateParser;
}

- (GCDateParser *)init
{
    self = [super init];
    
    if (self) {
        _cache = [NSMutableDictionary dictionary];
    }
	
	return self;
}

- (GCDate *)parseGedcom:(NSString *)str
{
    //NSLog(@"***** BEGIN PARSING **** %@ *****", str);
    @synchronized(_cache) {
        if (_cache[str]) {
            //NSLog(@"Getting cached date for %@", str);
            return [_cache[str] copy];
        }
        
        GCDate *date = nil;
        
        NSDateComponents *currentDateComponents = [[NSDateComponents alloc] init];
        [currentDateComponents setYear:0];
        [currentDateComponents setMonth:0];
        [currentDateComponents setDay:0];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        long tag = 0;
        NSInteger currentNumber = 0;
        NSString *currentString = nil;
        
        NSString *approximationQualifier = nil;
        id previousDate = nil;
        id currentDate = nil;
        
        BOOL finished = NO;
        
        int cs = 0;
        const char *data = [str UTF8String];
        const char *p = data;
        const char *pe = p + [str length];
        const char *eof = pe;
        
        %% write init;
        %% write exec;
        
        if (!finished) {
            date = nil;
        }
        
        if (date == nil) {
            date = [GCDate dateWithInvalidDateString:str];
        }
        
        _cache[str] = date;
        
        return date;
    }
}

@end