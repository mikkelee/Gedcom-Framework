//
//  GCChangedDateFormatter.h
//  GCCoreData
//
//  Created by Mikkel Eide Eriksen on 05/03/11.
//  Copyright 2011 Mikkel Eide Eriksen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
	Singleton to avoid the overhead of repeatedly creating new NSDateFormatters for the ChangedDates.
	
	Hardcoded to parse dates of format "dd MMM yyyy HH:mm:ss"
*/

@interface GCChangedDateFormatter : NSDateFormatter {

}

+ (GCChangedDateFormatter *)sharedFormatter;

@end
