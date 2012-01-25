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

#import "PATypeAheadFind.h"

@interface PATypeAheadFind (PrivateAPI)

- (void)updateMatchingTags;

@end

@implementation PATypeAheadFind

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		tags = [NNTags sharedTags];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark accessors
- (NSMutableArray*)activeTags
{
	return activeTags;
}

- (void)setActiveTags:(NSMutableArray*)someTags
{
	[someTags retain];
	[activeTags release];
	activeTags = someTags;
}

#pragma mark functionality
- (BOOL)hasTagsForPrefix:(NSString*)prefix
{
	// handle nil/empty prefix
	if (!prefix || [prefix isEqualToString:@""])
	{
		return YES;
	}
	
	NSEnumerator *e;
	
	// if active tags are set, look there, otherwise check in all tags
	if (activeTags)
	{
		e = [activeTags objectEnumerator];
	}
	else
	{
		e = [tags objectEnumerator];
	}
	
	NNTag *tag;
	
	while (tag = [e nextObject])
	{
		if (!NSEqualRanges([[tag name] rangeOfString:prefix options:(NSCaseInsensitiveSearch | NSAnchoredSearch | NSDiacriticInsensitiveSearch)],
						   NSMakeRange(NSNotFound,0)))
		{
			return true;
		}
	}
		
	// returns false if no tag was matching
	return false;
}

- (NSMutableArray*)tagsForPrefix:(NSString*)prefix
{
	if ([activeTags count] > 0)
	{
		return [self tagsForPrefix:prefix inTags:activeTags];
	}
	else
	{
		return [self tagsForPrefix:prefix inTags:[tags tags]];
	}
}

- (NSMutableArray*)tagsForPrefix:(NSString*)prefix inTags:(NSArray*)someTags
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [someTags objectEnumerator];
	NNTag *tag;
	
	while (tag = [e nextObject])
	{	
		if (!NSEqualRanges([[tag precomposedName] rangeOfString:prefix options:(NSCaseInsensitiveSearch | NSAnchoredSearch)],
						   NSMakeRange(NSNotFound,0)))
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

@end
