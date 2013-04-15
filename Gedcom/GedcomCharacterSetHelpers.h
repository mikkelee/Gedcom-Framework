//
//  GedcomCharacterSetHelpers.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline GCFileEncoding encodingForDataWithEncoding(NSData *data, NSStringEncoding tryEncoding) {
    NSRange searchRange = NSMakeRange(0, [data length] >= 1000 ? 1000 : [data length]-1);
    NSRange charSetRange = [data rangeOfData:[@"1 CHAR " dataUsingEncoding:tryEncoding]
                                     options:(kNilOptions)
                                       range:searchRange];
    
    if (charSetRange.location == NSNotFound) {
        if (tryEncoding == NSASCIIStringEncoding) {
            NSLog(@"Unknown encoding, going to try UTF8");
            return encodingForDataWithEncoding(data, NSUTF8StringEncoding);
        } else {
            NSLog(@"Unable to dertermine encoding");
            return GCUnknownFileEncoding;
        }
    }
    
    charSetRange.length = charSetRange.length + 7;
    
    NSString *charSetString = [[NSString alloc] initWithData:[data subdataWithRange:charSetRange]
                                                    encoding:tryEncoding];
    
    //NSLog(@"charSetString %@: %@", NSStringFromRange(charSetRange), charSetString);
    
    NSRegularExpression *characterSetRegex = [NSRegularExpression regularExpressionWithPattern:@"1 CHAR (ASCII|ANSEL|UNICODE|UTF-?8)"
                                                                                       options:(NSRegularExpressionCaseInsensitive)
                                                                                         error:nil];
    
    NSTextCheckingResult *match = [characterSetRegex firstMatchInString:charSetString
                                                                options:kNilOptions
                                                                  range:NSMakeRange(0, [charSetString length])];
    
    if (match) {
        NSString *characterSet = [charSetString substringWithRange:[match rangeAtIndex:1]];
        
        NSLog(@"encoding: %@", characterSet);
        
        if ([characterSet caseInsensitiveCompare:@"UNICODE"] == NSOrderedSame) {
            return GCUTF16FileEncoding; // spec refers to UTF16 as "UNICODE": http://www.gedcom.net/0g/gedcom55/55gcch3.htm#S3
        } else if ([characterSet hasPrefix:@"UTF"]) {
            return GCUTF8FileEncoding;
        } else if ([characterSet caseInsensitiveCompare:@"ANSEL"] == NSOrderedSame) {
            return GCANSELFileEncoding;
        } else if ([characterSet caseInsensitiveCompare:@"ASCII"] == NSOrderedSame) {
            return GCASCIIFileEncoding;
        } else {
            NSLog(@"Unknown encoding: %@", characterSet);
            return GCUnknownFileEncoding;
        }
    }
    
    return GCUnknownFileEncoding;
}

static inline GCFileEncoding encodingForData(NSData *data) {
    return encodingForDataWithEncoding(data, NSASCIIStringEncoding);
}

// created by anselmap.py via ans2uni.out from http://www.heiner-eichmann.de/gedcom/charintr.htm

static const unichar ansel2utf16[] = {
	0,  	1,  	2,  	3,  	4,  	5,  	6,  	7,  	8,  	9,
    10,  	11,  	12,  	13,  	14,  	15,  	16,  	17,  	18,  	19,
    20,  	21,  	22,  	23,  	24,  	25,  	26,  	27,  	28,  	29,
    30,  	31,  	32,  	33,  	34,  	35,  	36,  	37,  	38,  	39,
    40,  	41,  	42,  	43,  	44,  	45,  	46,  	47,  	48,  	49,
    50,  	51,  	52,  	53,  	54,  	55,  	56,  	57,  	58,  	59,
    60,  	61,  	62,  	63,  	64,  	65,  	66,  	67,  	68,  	69,
    70,  	71,  	72,  	73,  	74,  	75,  	76,  	77,  	78,  	79,
    80,  	81,  	82,  	83,  	84,  	85,  	86,  	87,  	88,  	89,
    90,  	91,  	92,  	93,  	94,  	95,  	96,  	97,  	98,  	99,
    100,  	101,  	102,  	103,  	104,  	105,  	106,  	107,  	108,  	109,
    110,  	111,  	112,  	113,  	114,  	115,  	116,  	117,  	118,  	119,
    120,  	121,  	122,  	123,  	124,  	125,  	126,  	127,  	128,  	129,
    130,  	131,  	132,  	133,  	134,  	135,  	136,  	137,  	138,  	139,
    140,  	141,  	142,  	143,  	144,  	145,  	146,  	147,  	148,  	149,
    150,  	151,  	152,  	153,  	154,  	155,  	156,  	157,  	158,  	159,
    160,
	/* ansel: 0xA1 => utf-16: */ 0x0141, // latin capital letter L with stroke
	/* ansel: 0xA2 => utf-16: */ 0x00D8, // latin capital letter O with stroke
	/* ansel: 0xA3 => utf-16: */ 0x0110, // latin capital letter D with stroke
	/* ansel: 0xA4 => utf-16: */ 0x00DE, // latin capital letter thorn
	/* ansel: 0xA5 => utf-16: */ 0x00C6, // latin capital letter AE
	/* ansel: 0xA6 => utf-16: */ 0x0152, // latin capital ligature OE
	/* ansel: 0xA7 => utf-16: */ 0x02B9, // modified letter prime
	/* ansel: 0xA8 => utf-16: */ 0x00B7, // middle dot
	/* ansel: 0xA9 => utf-16: */ 0x266D, // music flat sign
	/* ansel: 0xAA => utf-16: */ 0x00AE, // registered sign
	/* ansel: 0xAB => utf-16: */ 0x00B1, // plus-minus sign
	/* ansel: 0xAC => utf-16: */ 0x01A0, // latin capital letter O with horn
	/* ansel: 0xAD => utf-16: */ 0x01AF, // latin capital letter U with horn
	/* ansel: 0xAE => utf-16: */ 0x02BC, // modifier letter apostrophe
	175,
	/* ansel: 0xB0 => utf-16: */ 0x02BB, // modifier letter turned comma
	/* ansel: 0xB1 => utf-16: */ 0x0142, // latin small letter L with stroke
	/* ansel: 0xB2 => utf-16: */ 0x00F8, // latin small letter O with stroke
	/* ansel: 0xB3 => utf-16: */ 0x0111, // latin small letter D with stroke
	/* ansel: 0xB4 => utf-16: */ 0x00FE, // latin small letter thorn
	/* ansel: 0xB5 => utf-16: */ 0x00E6, // latin small letter AE
	/* ansel: 0xB6 => utf-16: */ 0x0153, // latin small ligature OE
	/* ansel: 0xB7 => utf-16: */ 0x02BA, // modified letter double prime
	/* ansel: 0xB8 => utf-16: */ 0x0131, // latin small letter dotless i
	/* ansel: 0xB9 => utf-16: */ 0x00A3, // pound sign
	/* ansel: 0xBA => utf-16: */ 0x00F0, // latin small letter eth
	187,
	/* ansel: 0xBC => utf-16: */ 0x01A1, // latin small letter O with horn
	/* ansel: 0xBD => utf-16: */ 0x01B0, // latin small letter U with horn
	190,  	191,
	/* ansel: 0xC0 => utf-16: */ 0x00B0, // degree sign
	/* ansel: 0xC1 => utf-16: */ 0x2113, // script small L
	/* ansel: 0xC2 => utf-16: */ 0x2117, // sound recording copyright
	/* ansel: 0xC3 => utf-16: */ 0x00A9, // copyright sign
	/* ansel: 0xC4 => utf-16: */ 0x266F, // music sharp sign
	/* ansel: 0xC5 => utf-16: */ 0x00BF, // inverted question mark
	/* ansel: 0xC6 => utf-16: */ 0x00A1, // inverted exclamation mark
	199,
    200,  	201,  	202,  	203,  	204,  	205,  	206,
	/* ansel: 0xCF => utf-16: */ 0x00DF, // latin small letter sharp S
	208,  	209,
    210,  	211,  	212,  	213,  	214,  	215,  	216,  	217,  	218,  	219,
    220,  	221,  	222,  	223,
	/* ansel: 0xE0 => utf-16: */ 0x0309, // combining hook above
	/* ansel: 0xE1 => utf-16: */ 0x0300, // combining grave accent
	/* ansel: 0xE2 => utf-16: */ 0x0301, // combining acute accent
	/* ansel: 0xE3 => utf-16: */ 0x0302, // combining circumflex accent
	/* ansel: 0xE4 => utf-16: */ 0x0303, // combining tilde
	/* ansel: 0xE5 => utf-16: */ 0x0304, // combining macron
	/* ansel: 0xE6 => utf-16: */ 0x0306, // combining breve
	/* ansel: 0xE7 => utf-16: */ 0x0307, // combining dot above
	/* ansel: 0xE8 => utf-16: */ 0x0308, // combining diaeresis
	/* ansel: 0xE9 => utf-16: */ 0x030C, // combining caron
	/* ansel: 0xEA => utf-16: */ 0x030A, // combining ring above
	/* ansel: 0xEB => utf-16: */ 0xFE20, // combining ligature left half
	/* ansel: 0xEC => utf-16: */ 0xFE21, // combining ligature right half
	/* ansel: 0xED => utf-16: */ 0x0315, // combining comma above right
	/* ansel: 0xEE => utf-16: */ 0x030B, // combining double acute accent
	/* ansel: 0xEF => utf-16: */ 0x0310, // combining candrabindu
	/* ansel: 0xF0 => utf-16: */ 0x0327, // combining cedilla
	/* ansel: 0xF1 => utf-16: */ 0x0328, // combining ogonek
	/* ansel: 0xF2 => utf-16: */ 0x0323, // combining dot below
	/* ansel: 0xF3 => utf-16: */ 0x0324, // combining diaeresis below
	/* ansel: 0xF4 => utf-16: */ 0x0325, // combining ring below
	/* ansel: 0xF5 => utf-16: */ 0x0333, // combining double low line
	/* ansel: 0xF6 => utf-16: */ 0x0332, // combining low line
	/* ansel: 0xF7 => utf-16: */ 0x0326, // combining comma below
	/* ansel: 0xF8 => utf-16: */ 0x031C, // combining left half ring below
	/* ansel: 0xF9 => utf-16: */ 0x032E, // combining breve below
	/* ansel: 0xFA => utf-16: */ 0xFE22, // combining double tilde left half
	/* ansel: 0xFB => utf-16: */ 0xFE23, // combining double tilde right half
	252,  	253,
	/* ansel: 0xFE => utf-16: */ 0x0313, // combining comma above
	255,
};

static inline NSString * stringFromANSELData(NSData *input) {
    int outLen = (int)[input length];
    unichar outBytes[outLen];
    
    const unsigned char *inBytes = [input bytes];
    
    for (int i = 0; i <= outLen; i++) {
        unsigned char b = inBytes[i];
        outBytes[i] = ansel2utf16[b];
        //NSLog(@"%d/%d: %c (%d) => (%d) %C", i, outLen, b, b, ansel2utf16[b], outBytes[i]);
    }
    
    NSString *outString = [NSString stringWithCharacters:outBytes length:outLen];
    
    return outString;
}

