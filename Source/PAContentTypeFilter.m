// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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

#import "PAContentTypeFilter.h"

@interface PAContentTypeFilter (PrivateAPI)

- (void)createFiltersForContentType:(NSString*)contentType;

@end

@implementation PAContentTypeFilter

#pragma mark init
- (id)initWithContentType:(NSString*)type
{
	if (self = [super init])
	{
		weight = 10;
		contentType = [type copy];
		
		tagCache = [PATagCache sharedInstance];
		
		selectedTags = [[NNSelectedTags alloc] init];
		query = [[NNQuery alloc] initWithTags:selectedTags];
				
		NNContentTypeTreeQueryFilter *filter = [NNContentTypeTreeQueryFilter contentTypeTreeQueryFilterForType:type];
		[query addFilter:filter];
	}
	return self;
}

- (void)dealloc
{
	[query release];
	[selectedTags release];
	[contentType release];
	[super dealloc];
}

+ (PAContentTypeFilter*)filterWithContentType:(NSString*)type
{
	PAContentTypeFilter* filter = [[PAContentTypeFilter alloc] initWithContentType:type];
	return [filter autorelease];
}

#pragma mark accessors
- (NSString*)contentType
{
	return contentType;
}

#pragma mark function
- (void)filterObject:(id)object
{
	[super filterObject:object];
	
	// look if cache can satisfy request
	PACacheResult result = [tagCache checkFiletype:[self contentType] forTag:object];
	
	if (result & PACacheIsValid)
	{
		if (result & PACacheSatisfiesRequest)
		{
			// cache was valid and object is good to go			
			[self objectFiltered:object];
		}
	}
	else
	{
		// execute a query with the given tag to see if it has any files
		// matching the content type
		[selectedTags setSelectedTags:[NSArray arrayWithObject:object]];
		NSArray *results = [query executeSynchronousQuery];
		
		if ([results count] > 0)
		{
			// update cache
			[tagCache updateCacheForTag:object
							setFiletype:[self contentType]
								toValue:YES];
			
			[self objectFiltered:object];
		}
		else
		{
			// update cache
			[tagCache updateCacheForTag:object
							setFiletype:[self contentType]
								toValue:NO];
		}
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"PAContentTypeFilter: %@",contentType];
}

@end
