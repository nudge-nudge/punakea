// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSDateFormatter+FriendlyFormat.h"


@implementation NSDateFormatter (FriendlyFormat)

// TODO: Localize!

- (NSString *)friendlyStringFromDate:(NSDate *)date
{
	if(!date) return NSLocalizedStringFromTable(@"NO_DATE",@"Global",@"");
	
	// Save current styles
	NSDateFormatterStyle dateStyle = [self dateStyle];
	NSDateFormatterStyle timeStyle = [self timeStyle];
	
	NSCalendarDate *cdate = [date dateWithCalendarFormat:nil timeZone:nil];
	NSInteger today = [[NSCalendarDate calendarDate] dayOfCommonEra];
	NSInteger dateDay = [cdate dayOfCommonEra];
	
	NSString *value = nil;
	
	if(dateDay == today)		value = NSLocalizedStringFromTable(@"TODAY",@"Global",@"");
	if(dateDay == (today - 1))	value = NSLocalizedStringFromTable(@"YESTERDAY",@"Global",@"");
	
	if(value)
	{
		// Append time to our friendly string
		
		[self setDateStyle:NSDateFormatterNoStyle];
		[self setTimeStyle:NSDateFormatterShortStyle];
		
		value = [value stringByAppendingString:@" "];
		value = [value stringByAppendingString:[self stringFromDate:date]];
	}
	else if ([date isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]])
	{
		// date was created by passing 0 - display never
		  value = NSLocalizedStringFromTable(@"NEVER",@"Global",@"");
	}
	else
	{
		// Show only month and year if this is an older date		
		if([date timeIntervalSinceNow] > [[NSNumber numberWithInteger:-60*60*24*40] doubleValue])
		{
			[self setTimeStyle:NSDateFormatterShortStyle];
		} else {
			[self setDateFormat:@"MMMM yyyy"];
		}
		
		value = [self stringFromDate:date];
	}
	
	// Restore styles
	[self setDateStyle:dateStyle];
	[self setTimeStyle:timeStyle];

	return value;
}

- (NSString *)saveStringFromDate:(NSDate *)date
{
	NSString *s = [self stringFromDate:date];
	
	return s ? s : NSLocalizedStringFromTable(@"NO_DATE",@"Global",@"");
}

@end
