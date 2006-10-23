//
//  NSDateFormatter+FriendlyFormat.m
//  punakea
//
//  Created by Daniel on 10/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSDateFormatter+FriendlyFormat.h"


@implementation NSDateFormatter (FriendlyFormat)

// TODO: Localize!

- (NSString *)friendlyStringFromDate:(NSDate *)date
{
	if(!date) return @"No Date";
	
	NSCalendarDate *cdate = [date dateWithCalendarFormat:nil timeZone:nil];
	int today = [[NSCalendarDate calendarDate] dayOfCommonEra];
	int dateDay = [cdate dayOfCommonEra];
	
	NSString *value = nil;
	
	if(dateDay == today)		value = @"Today";
	if(dateDay == (today - 1))	value = @"Yesterday";
	
	if(value)
	{
		// Append time to our friendly string
		
		NSDateFormatterStyle style = [self dateStyle];
		
		[self setDateStyle:NSDateFormatterNoStyle];
		[self setTimeStyle:NSDateFormatterShortStyle];
		
		value = [value stringByAppendingString:@" "];
		value = [value stringByAppendingString:[self stringFromDate:date]];
		
		[self setDateStyle:style];
	}
	else
	{
		// Show only month and year if this is an older date		
		if([date timeIntervalSinceNow] > [[NSNumber numberWithInt:-60*60*24*40] doubleValue])
		{
			[self setTimeStyle:NSDateFormatterShortStyle];
		} else {
			[self setDateFormat:@"MMMM yyyy"];
		}
		
		value = [self stringFromDate:date];
	}

	return value;
}

@end
