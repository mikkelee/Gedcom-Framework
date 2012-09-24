//
//  ANSELHelpers.h
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
            return GCUTF16StringEncoding; // spec refers to UTF16 as "UNICODE": http://www.gedcom.net/0g/gedcom55/55gcch3.htm#S3
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
	0x0141, // latin capital letter L with stroke
	0x00D8, // latin capital letter O with stroke
	0x0110, // latin capital letter D with stroke
	0x00DE, // latin capital letter thorn
	0x00C6, // latin capital letter AE
	0x0152, // latin capital ligature OE
	0x02B9, // modified letter prime
	0x00B7, // middle dot
	0x266D, // music flat sign
	0x00AE, // registered sign
	0x00B1, // plus-minus sign
	0x01A0, // latin capital letter O with horn
	0x01AF, // latin capital letter U with horn
	0x02BC, // modifier letter apostrophe
	175,
	0x02BB, // modifier letter turned comma
	0x0142, // latin small letter L with stroke
	0x00F8, // latin small letter O with stroke
	0x0111, // latin small letter D with stroke
	0x00FE, // latin small letter thorn
	0x00E6, // latin small letter AE
	0x0153, // latin small ligature OE
	0x02BA, // modified letter double prime
	0x0131, // latin small letter dotless i
	0x00A3, // pound sign
	0x00F0, // latin small letter eth
	187,
	0x01A1, // latin small letter O with horn
	0x01B0, // latin small letter U with horn
	190,  	191,
	0x00B0, // degree sign
	0x2113, // script small L
	0x2117, // sound recording copyright
	0x00A9, // copyright sign
	0x266F, // music sharp sign
	0x00BF, // inverted question mark
	0x00A1, // inverted exclamation mark
	199,  	200,  	201,  	202,  	203,  	204,  	205,  	206,
	0x00DF, // latin small letter sharp S
	208,  	209,
    210,  	211,  	212,  	213,  	214,  	215,  	216,  	217,  	218,  	219,
    220,  	221,  	222,  	223,
	0x0309, // combining hook above
	0x0300, // combining grave accent
	0x0301, // combining acute accent
	0x0302, // combining circumflex accent
	0x0303, // combining tilde
	0x0304, // combining macron
	0x0306, // combining breve
	0x0307, // combining dot above
	0x0308, // combining diaeresis
	0x030C, // combining caron
	0x030A, // combining ring above
	0xFE20, // combining ligature left half
	0xFE21, // combining ligature right half
	0x0315, // combining comma above right
	0x030B, // combining double acute accent
	0x0310, // combining candrabindu
	0x0327, // combining cedilla
	0x0328, // combining ogonek
	0x0323, // combining dot below
	0x0324, // combining diaeresis below
	0x0325, // combining ring below
	0x0333, // combining double low line
	0x0332, // combining low line
	0x0326, // combining comma below
	0x031C, // combining left half ring below
	0x032E, // combining breve below
	0xFE22, // combining double tilde left half
	0xFE23, // combining double tilde right half
	252,  	253,
	0x0313, // combining comma above
	255,
};

static inline NSString * stringFromANSELData(NSData *input) {
    const char *inBytes = [input bytes];
    int outLen = (int)[input length];
    unichar outBytes[outLen];
    
    for (int i = 0; i <= outLen; i++) {
        char b = inBytes[i];
        outBytes[i] = ansel2utf16[b];
        //NSLog(@"%d/%d: %c => %C", i, outLen, b, outBytes[i]);
    }
    
    NSString *outString = [NSString stringWithCharacters:outBytes length:outLen];
    
    return outString;
}

