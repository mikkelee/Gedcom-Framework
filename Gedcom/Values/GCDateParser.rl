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
        [currentDateComponents setMonth:[_gregorianMonthNames indexOfObject:currentString]+1];
		//NSLog(@"%p saveMonthWord: %d", fpc, currentNumber);
	}
	
	action saveMonthFren {
        [currentDateComponents setMonth:[_frenchRevolutionaryMonthNames indexOfObject:currentString]+1];
		//NSLog(@"%p saveMonthFren: %d", fpc, currentNumber);
	}
	
	action saveMonthHebr {
        [currentDateComponents setMonth:[_hebrewMonthNames indexOfObject:currentString]+1];
		//NSLog(@"%p saveMonthHebr: %d", fpc, currentNumber);
	}
	
	action saveYear {
        [currentDateComponents setYear:currentNumber];
		//NSLog(@"%p saveYears: %d", fpc, currentNumber);
	}
	
	action saveYearGreg {
        yearGreg = currentString;
		//NSLog(@"%p saveYears: %d", fpc, currentNumber);
	}
    
    action setCalendarGregorian {
        calendar = _gregorianCalendar;
    }
    
    action setCalendarJulian {
        // NSGregorianCalendar has Julian October 4, 1582 >>> Gregorian October 15, 1582
        calendar = _gregorianCalendar;
    }
    
    action setCalendarHebrew {
        calendar = _hebrewCalendar;
    }
    
    action setCalendarFrenchRevolutionary {
        calendar = _frenchRevolutionaryCalendar;
    }
    
    action saveApproximationQualifier {
        approximationQualifier = currentString;
    }
    
    action resetDate {
		//NSLog(@"%p saveDatePart.", fpc);
        
        previousDate = currentDate;
        
        currentDateComponents = [[NSDateComponents alloc] init];
        [currentDateComponents setYear:0];
        [currentDateComponents setMonth:0];
        [currentDateComponents setDay:0];
        [currentDateComponents setHour:0];
        [currentDateComponents setMinute:0];
        [currentDateComponents setSecond:0];
        [currentDateComponents setTimeZone:_utc];
        
        currentDate = nil;
    }
    
    action saveDateSimple {
		//NSLog(@"%p saveDateSimple.", fpc);
        currentDate = [GCDate dateWithSimpleDate:currentDateComponents calendar:calendar];
        if (yearGreg) {
            ((GCSimpleDate *)currentDate).yearGregSuffix = yearGreg;
        }
        yearGreg = nil;
    }
    
    action saveDateApproximate {
		//NSLog(@"%p saveDateApproximate.", fpc);
        currentDate = [GCDate dateWithApproximateDate:currentDate type:approximationQualifier];
    }
    
    action saveDatePhrase {
		//NSLog(@"%p saveDatePhrase.", fpc);
        currentDate = [GCDate dateWithPhrase:currentString];
    }
    
    action saveDateInterpreted {
		//NSLog(@"%p saveDateInterpreted.", fpc);
        currentDate = [GCDate dateWithInterpretedDate:previousDate phrase:currentDate];
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
    yearGregSuffix      = ( '/' digit digit ) >tag %string %saveYearGreg;
	yearGreg			= ( year | ( year yearGregSuffix ) );
	
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
	
	dateInterpreted		= ( 'INT ' dateSimple %resetDate ' ' datePhrase ) %saveDateInterpreted;
	
	dateApproximated	= ( ('ABT' | 'CAL' | 'EST') >tag %string %saveApproximationQualifier ' ' dateSimple ) %saveDateApproximate;
	
	dateRange			= ( ('BET ' dateSimple %resetDate ' AND ' dateSimple)
						  | ('BEF ' dateSimple)
						  | ('AFT ' dateSimple %resetDate)
                          ) %saveDateRange ;
	
	datePeriod			= ( ('FROM ' dateSimple %resetDate ' TO ' dateSimple)
						  | ('FROM ' dateSimple %resetDate)
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

@implementation GCDateParser

__strong static id _sharedDateParser = nil;
__strong static NSTimeZone *_utc;
__strong static NSCalendar *_gregorianCalendar;
__strong static NSCalendar *_hebrewCalendar;
__strong static NSCalendar *_frenchRevolutionaryCalendar;
__strong static NSArray *_gregorianMonthNames;
__strong static NSArray *_hebrewMonthNames;
__strong static NSArray *_frenchRevolutionaryMonthNames;

+ (void)initialize
{
    _sharedDateParser = [[self alloc] init];
    
    _utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    _gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [_gregorianCalendar setTimeZone:_utc];
    
    _hebrewCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar];
    [_hebrewCalendar setTimeZone:_utc];
    
    //TODO, french revolutionariy calendar doesn't exist in ICU...
    _frenchRevolutionaryCalendar = nil;

    _gregorianMonthNames = @[ @"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC" ];

    _hebrewMonthNames = @[ @"TSH", @"CSH", @"KSL", @"TVT", @"SHV", @"ADR", @"ADS", @"NSN", @"IYR", @"SVN", @"TMZ", @"AAV", @"ELL" ];

    _frenchRevolutionaryMonthNames = @[ @"VEND", @"BRUM", @"FRIM", @"NIVO", @"PLUV", @"VENT", @"GERM", @"FLOR", @"PRAI", @"MESS", @"THER", @"FRUC", @"COMP" ];

}

+ (id)sharedDateParser
{
    return _sharedDateParser;
}

- (GCDate *)parseGedcom:(NSString *)str
{
    GCDate *date = nil;

    NSDateComponents *currentDateComponents = [[NSDateComponents alloc] init];
    [currentDateComponents setYear:0];
    [currentDateComponents setMonth:0];
    [currentDateComponents setDay:0];
    [currentDateComponents setHour:0];
    [currentDateComponents setMinute:0];
    [currentDateComponents setSecond:0];
    [currentDateComponents setTimeZone:_utc];
    NSCalendar *calendar = _gregorianCalendar;

    long tag = 0;
    NSInteger currentNumber = 0;
    NSString *currentString = nil;

    NSString *yearGreg = nil;

    NSString *approximationQualifier = nil;
    id previousDate = nil;
    id currentDate = nil;

    BOOL finished = NO;

    int cs = 0;
    const char *data = [str UTF8String];
    const char *p = data;
    const char *pe = p + [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char *eof = pe;

    %% write init;
    %% write exec;

    if (!finished) {
        date = nil;
    }
    
    if (date == nil) {
        date = [GCDate dateWithInvalidDateString:str];
    }
    
    return date;
}

@end