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

#import "PAStringFilter.h"


@implementation PAStringFilter

#pragma mark init
- (id)initWithFilter:(NSString*)filterString
{
	if (self = [super init])
	{
		weight = 1;
		filter = [[filterString lowercaseString] copy];
	}
	return self;
}

- (void)dealloc
{
	[filter release];
	[super dealloc];
}

#pragma mark accessors
- (NSString*)filter
{
	return filter;
}

#pragma mark function
- (void)filterObject:(id)object
{
	NSString *tagName = [object name];
	
	if (!NSEqualRanges([tagName rangeOfString:filter options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)], 
					   NSMakeRange(NSNotFound,0)))
	{
		[self objectFiltered:object];
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"StringFilter: %@",filter];
}

@end
