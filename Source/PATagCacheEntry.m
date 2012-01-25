// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PATagCacheEntry.h"


@implementation PATagCacheEntry

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		[self setAssignedFiletypes:[NSMutableDictionary dictionary]];
		lock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[lock release];
	[assignedFiletypes release];
	[super dealloc];
}

#pragma mark coding
- (id)initWithCoder:(NSCoder*)coder 
{
	self = [super init];
	if (self) 
	{
		[self setAssignedFiletypes:[coder decodeObjectForKey:@"assignedFiletypes"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{
	[coder encodeObject:assignedFiletypes forKey:@"assignedFiletypes"];
}

#pragma mark accessors
- (void)setAssignedFiletypes:(NSMutableDictionary*)dic
{
	[lock lock];
	[dic retain];
	[assignedFiletypes release];
	assignedFiletypes = dic;
	[lock unlock];
}

- (NSMutableDictionary*)assignedFiletypes
{
	return assignedFiletypes;
}

#pragma mark function
- (void)setHasFiletype:(NSString*)filetype toValue:(BOOL)hasFiletype
{
	NSArray *values = [NSArray arrayWithObjects:[NSCalendarDate date],[NSNumber numberWithBool:hasFiletype],nil];
	
	[lock lock];
	[assignedFiletypes setObject:values forKey:filetype];
	[lock unlock];
}		

- (PACacheResult)hasFiletype:(NSString*)filetype forDate:(NSDate*)date
{
	PACacheResult result = 0;
	
	NSArray *values = [assignedFiletypes objectForKey:filetype];
	
	if (values)
	{
		NSCalendarDate *cacheDate = [values objectAtIndex:0];
		
		if ([cacheDate compare:date] != NSOrderedAscending)
		{
			result = PACacheIsValid;
		}
		
		if ([[values objectAtIndex:1] boolValue])
		{
			result = result | PACacheSatisfiesRequest;
		}
	}
	
	return result;
}

@end
